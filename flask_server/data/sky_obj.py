import warnings

import astropy.units as u
import pytz
from astroplan.exceptions import *

from astropy.coordinates import EarthLocation, SkyCoord, AltAz
from astroplan import Observer, FixedTarget
from astropy.time import Time
from datetime import datetime, timedelta

from timezonefinder import TimezoneFinder

from data.obj_util import ObjUtil

warnings.filterwarnings("error")


class SkyObject:
    """ Allows positional measurement of object at certain time, date and location.
    :param start_time: The time at which observation begins
    :param obj_name: The name of the object, in catalog format, e.g. M31 (if not a heliocentric body).
    :param coords: The (latitude, longitude) coordinate pair of the observation site
    """

    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float), threshold: float):

        self.coords = coords
        self.utc_td = timedelta(hours=self.utc_offset(self.coords))

        self.start_time = start_time
        self.end_time = end_time
        self.obj_name = obj_name

        self.geo_loc = EarthLocation.from_geodetic(lat=coords[0], lon=coords[1])

        self.target = FixedTarget.from_name(obj_name)
        self.observer_loc = Observer(latitude=coords[0], longitude=coords[1])
        self.threshold = threshold

        self.needs_mer_flip = self.peak_alt_az['alt'] >= 87.0 * u.deg

        self.target_always_up = False
        self.target_always_down = False

        self.sun_always_up = False
        self.sun_always_down = False

        try:
            self.rise_iso = self.observer_loc.target_rise_time(start_time, self.target)
            self.set_iso = self.observer_loc.target_set_time(start_time, self.target)

        except TargetAlwaysUpWarning:
            self.rise_iso = self.obj_rise_time = None
            self.set_iso = self.obj_set_time = None
            self.target_always_up = True

        except TargetNeverUpWarning:
            self.rise_iso = self.obj_rise_time = None
            self.set_iso = self.obj_set_time = None
            self.target_always_down = True

        # Initializes sunset and sunrise, if applicable
        try:
            self.sunrise_iso = self.observer_loc.sun_rise_time(start_time, which='nearest')
            self.sunset_iso = self.observer_loc.sun_set_time(start_time, which='nearest')

        except TargetAlwaysUpWarning:
            self.sunset_iso = None
            self.sun_always_up = True

        except TargetNeverUpWarning:
            self.sunset_iso = None
            self.sun_always_down = True

        if not (self.sun_always_down or self.sun_always_up):  # DeMorgan \Ö/

            __sunrise_t = self.observer_loc.sun_rise_time(start_time, which='nearest').to_datetime()
            __sunset_t = self.observer_loc.sun_set_time(start_time, which='nearest').to_datetime()

            self.sunrise_t = (__sunrise_t + self.utc_td).time()
            self.sunset_t = (__sunset_t + self.utc_td).time()

        if not (self.target_always_down or self.target_always_up):
            self.rise_iso = self.observer_loc.target_rise_time(start_time, self.target) + self.utc_td
            self.set_iso = self.observer_loc.target_set_time(start_time, self.target) + self.utc_td

            self.obj_rise_time = datetime.fromisoformat(self.rise_iso.iso).time()
            self.obj_set_time = datetime.fromisoformat(self.set_iso.iso).time()

    @staticmethod
    def loc_utc_str(coords):
        tz_str = TimezoneFinder().timezone_at(lat=coords[0], lng=coords[1])
        return pytz.timezone(tz_str)

    @staticmethod
    def utc_offset(coords) -> float:
        timezone = SkyObject.loc_utc_str((coords[0], coords[1]))
        return timezone.utcoffset(datetime.now()).total_seconds() // 3600

    @property
    def hours_visible(self) -> [datetime]:
        return ObjUtil.hours_visible(
            target_always_up=self.target_always_up,
            target_always_down=self.target_always_down,
            sun_always_up=self.sun_always_up,
            sun_always_down=self.sun_always_down,
            start_time=self.start_time,
            end_time=self.end_time,
            obj_rise_time=self.obj_rise_time,
            obj_set_time=self.obj_set_time,
            sunrise_t=self.sunrise_t,
            sunset_t=self.sunset_t
        )

    @property
    def alt_az_pos(self) -> SkyCoord:
        obj_coords = SkyCoord.from_name(self.obj_name)

        return obj_coords.transform_to(AltAz(obstime=self.start_time - self.utc_td, location=self.geo_loc))

    @property
    def peak_alt_az(self) -> [float]:
        peak_iso = self.peak_time

        obj_coords = SkyCoord.from_name(self.obj_name)

        alt = obj_coords.transform_to(AltAz(obstime=peak_iso, location=self.geo_loc)).alt
        az = obj_coords.transform_to(AltAz(obstime=peak_iso, location=self.geo_loc)).az

        return {'alt': alt, 'az': az}

    @property
    def peak_time(self) -> str:
        loc = self.observer_loc

        time = loc.target_meridian_transit_time(self.start_time - self.utc_td, self.target)

        return time.iso

    @property
    def suggested_hours(self) -> [datetime] or str:

        if self.threshold <= -1:
            return [-1]

        elif self.hours_visible[0] == -1:
            return [-1]

        alt_threshold = 20.0 * u.deg

        start_dt = datetime.combine(self.start_time.to_datetime().date(), self.hours_visible[0])
        end_dt = datetime.combine(self.end_time.to_datetime().date(), self.hours_visible[1])

        t_interval = ((end_dt - start_dt) / 12)  # 12 to hold balance between precision and speed

        points = [start_dt + (i * t_interval) for i in range(1, 12)]

        points[-1] = end_dt

        times = []

        times_i = -1

        for t_point in points:  # Filters times

            t = Time(t_point).to_datetime()

            altitude = self.observer_loc.altaz(time=t-self.utc_td, target=self.target).alt

            if altitude >= alt_threshold:
                if len(times) >= 2 and times[times_i] - t_interval == times[times_i - 1]:  # Ensures no gaps
                    times.append(t_point)
                    times_i += 1
                elif len(times) < 2:
                    times.append(t_point)
                    times_i += 1

        if len(times) < 2:
            return [-1]

        return [times[0].isoformat(), times[-1].isoformat()]
