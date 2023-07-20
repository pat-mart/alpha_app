import sys
import warnings

import astropy.units as u
import pytz
from astroplan.exceptions import *

from astropy.coordinates import EarthLocation, SkyCoord, AltAz
from astroplan import Observer, FixedTarget
from astropy.time import Time
from datetime import datetime, timedelta, time

from erfa import ErfaWarning
from timezonefinder import TimezoneFinder


warnings.filterwarnings("error")

class SkyObject:
    """ Allows positional measurement of object at certain time, date and location.
    :param start_time: The time at which observation begins
    :param obj_name: The name of the object, in catalog format, e.g. M31 (if not a heliocentric body).
    :param coords: The (latitude, longitude) coordinate pair of the observation site
    """

    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float)):
        self.start_time = start_time
        self.end_time = end_time
        self.obj_name = obj_name
        self.coords = coords
        self.geo_loc = EarthLocation.from_geodetic(coords[0], coords[1])

        self.target = FixedTarget.from_name(obj_name)
        self.observer_loc = Observer(latitude=coords[0], longitude=coords[1])

        self.needs_mer_flip = False

        self.target_sets = True
        self.target_rises = True

        self.sun_rises = True
        self.sun_sets = True

        try:
            self.rise_iso = self.observer_loc.target_rise_time(start_time, self.target) + timedelta(hours=self.utc_offset)
            self.set_iso = self.observer_loc.target_set_time(start_time, self.target) + timedelta(hours=self.utc_offset)

            self.obj_rise_time = datetime.fromisoformat(self.rise_iso.iso).time()
            self.obj_set_time = datetime.fromisoformat(self.set_iso.iso).time()
        except TargetAlwaysUpWarning:
            self.set_iso = None
            self.target_sets = False
        except TargetNeverUpWarning:
            self.rise_iso = None
            self.target_sets = False

        try:
            self.sunrise_iso = self.observer_loc.sun_rise_time(start_time, which='nearest') + timedelta(hours=self.utc_offset)
            self.sunset_iso = self.observer_loc.sun_set_time(start_time, which='nearest') + timedelta(hours=self.utc_offset)

            self.sunrise_t = datetime.fromisoformat(self.sunrise_iso.iso).time()
            self.sunset_t = datetime.fromisoformat(self.sunset_iso.iso).time()
        except TargetAlwaysUpWarning:
            self.sunset_iso = None
            self.sun_sets = False
        except TargetNeverUpWarning:
            self.sunset_iso = None
            self.sun_rises = False

    @property
    def loc_utc_str(self):
        tz_str = TimezoneFinder().timezone_at(lat=self.coords[0], lng=self.coords[1])

        return pytz.timezone(tz_str)

    """
    :return The UTC offset in hours. Automatically accounts for daylight savings.
    """

    @property
    def utc_offset(self) -> float:
        timezone = self.loc_utc_str
        return timezone.utcoffset(datetime.now()).total_seconds() // 3600

    @property
    def hours_visible(self) -> [datetime]:

        rise_time = self.obj_rise_time
        set_time = self.obj_set_time

        sunrise_t = self.sunrise_t
        sunset_t = self.sunset_t

        if not self.sun_sets or not self.target_rises:
            return [-1, -1]

        elif not self.target_sets and not self.sun_rises:
            return [self.start_time.to_datetime(), self.end_time.to_datetime()]

        elif rise_time > sunset_t and set_time < sunrise_t:  # Object rises and sets between sunset and sunrise
            return [rise_time, set_time]

        elif rise_time > sunrise_t and set_time > sunset_t:  # Object rises during day, sets at night
            return [sunset_t, set_time]

        elif rise_time < sunrise_t and set_time < sunset_t:  # Object rises at night (early morning), sets during day
            return [rise_time, sunrise_t]

        elif rise_time > sunset_t and set_time > sunrise_t:  # Object rises at night (after sunset), sets during day
            return [rise_time, sunrise_t]

        return [-1, -1]

    @property
    def alt_az_pos(self) -> SkyCoord:
        obj_coords = SkyCoord.from_name(self.obj_name)

        return obj_coords.transform_to(AltAz(obstime=self.start_time - self.utc_offset, location=self.geo_loc))

    @property
    def peak_alt(self) -> float:
        loc = self.observer_loc

        peak_iso = loc.target_meridian_transit_time(
            self.start_time, self.target, which='nearest') + timedelta(hours=self.utc_offset)

        print(peak_iso.iso, file=sys.stdout)

        obj_coords = SkyCoord.from_name(self.obj_name)

        return obj_coords.transform_to(AltAz(obstime=peak_iso - self.utc_offset, location=self.geo_loc)).alt

    @property
    def suggested_hours(self) -> [datetime]:

        if self.hours_visible[0] == -1:
            return []

        alt_threshold = 20.0 * u.deg

        start_dt = datetime.combine(self.start_time.to_datetime().date(), self.hours_visible[0])
        end_dt = datetime.combine(self.end_time.to_datetime().date(), self.hours_visible[1])

        t_interval = ((end_dt - start_dt) / 15)  # FIXME can be more precise

        points = [start_dt + (i * t_interval) for i in range(1, 15)]

        times = []

        times_i = -1

        for t_point in points:  # Filters times

            print(times_i, len(times))

            t = Time(t_point).to_datetime()

            altitude = self.observer_loc.altaz(time=t - timedelta(hours=self.utc_offset), target=self.target).alt

            if altitude > alt_threshold:
                if len(times) >= 2 and times[times_i] - t_interval == times[times_i - 1]:
                    times.append(t_point)
                    times_i += 1
                elif len(times) < 2:
                    times.append(t_point)
                    times_i += 1

        return times
