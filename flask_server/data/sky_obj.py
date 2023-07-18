import sys

import astropy.units as u
import pytz

from astropy.coordinates import EarthLocation, SkyCoord, AltAz
from astroplan import Observer, FixedTarget
from astropy.time import Time
from datetime import datetime, timedelta
from timezonefinder import TimezoneFinder


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

        self.rise_iso = self.observer_loc.target_rise_time(start_time, self.target) + timedelta(hours=self.utc_offset)
        self.set_iso = self.observer_loc.target_set_time(start_time, self.target) + timedelta(hours=self.utc_offset)

        self.sunrise_iso = self.observer_loc.sun_rise_time(start_time, which='nearest') \
                           + timedelta(hours=self.utc_offset)

        self.sunset_iso = self.observer_loc.sun_set_time(start_time, which='nearest') + timedelta(hours=self.utc_offset)

        self.obj_rise_time = datetime.fromisoformat(self.rise_iso.iso).time()
        self.obj_set_time = datetime.fromisoformat(self.set_iso.iso).time()

        self.sunrise_t = datetime.fromisoformat(self.sunrise_iso.iso).time()
        self.sunset_t = datetime.fromisoformat(self.sunset_iso.iso).time()

        self.is_day_vis = self.obj_name in ['moon', 'sun', 'venus']

    def __filtered_hours(self, hours: [], limit: timedelta) -> [datetime]:

        for i in range(len(hours) - 1):
            c_time = hours[i]
            n_time = hours[i + 1]

            t_diff = timedelta(
                hours=n_time.hour - c_time.hour,
                minutes=n_time.minute - c_time.minute
            )

            if t_diff.total_seconds() > limit.total_seconds() and t_diff.total_seconds() > 0:
                hours.pop(i)

        return hours

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

        print(rise_time > sunset_t, set_time < sunset_t)

        # FIXME implement differentiation between never rise and never set objects

        if self.is_day_vis:
            return [rise_time, set_time]

        if rise_time > sunset_t and set_time < sunrise_t:  # Object rises and sets between sunset and sunrise
            return [rise_time, set_time]

        elif rise_time > sunrise_t and set_time > sunset_t:  # Object rises during day, sets at night
            return [sunset_t, set_time]

        elif rise_time < sunrise_t and set_time < sunset_t:  # Object rises at night (early morning), sets during day
            return [rise_time, sunrise_t]

        elif rise_time > sunset_t and set_time > sunrise_t: # Object rises at night (after sunset), sets during day
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

        set_time = self.obj_set_time

        loc = self.observer_loc

        dark_t = loc.twilight_evening_astronomical(self.start_time) + timedelta(hours=self.utc_offset)
        dusk_t = loc.twilight_morning_astronomical(self.start_time) + timedelta(hours=self.utc_offset)

        evening_dark_time = datetime.fromisoformat(dark_t.iso).time()

        start_dt = datetime.combine(self.start_time.to_datetime().date(), self.hours_visible[0])
        end_dt = datetime.combine(self.end_time.to_datetime().date(), self.hours_visible[1])

        t_interval = ((end_dt - start_dt) / 15)  # FIXME

        points = [start_dt + (i * t_interval) for i in range(1, 15)]

        times = []

        for t_point in points:

            t = Time(t_point)

            altitude = self.observer_loc.altaz(time=t - timedelta(hours=self.utc_offset), target=self.target).alt

            if altitude > alt_threshold:
                times.append(t_point.time().isoformat())

        return times
