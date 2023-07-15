import sys
import time

import astropy.units as u
import numpy as np
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
    :param elev: The elevation of the observation site.
    """

    def __init__(self, start_time: Time, duration: timedelta, obj_name: str, coords: (float, float)):
        self.start_time = start_time
        self.duration = duration
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
    def hours_visible(self) -> [str]:

        rise_time = self.obj_rise_time
        set_time = self.obj_set_time

        sunrise_t = self.sunrise_t
        sunset_t = self.sunset_t

        if rise_time > sunset_t and set_time < sunrise_t:  # Object rises and sets during night
            return [rise_time.isoformat(), set_time.isoformat()]

        elif rise_time > sunrise_t and set_time > sunset_t:  # Object rises during day, sets at night
            return [sunset_t.isoformat(), set_time.isoformat()]

        elif rise_time > sunset_t and set_time > sunrise_t:  # Object rises at night, sets after sunrise
            return [rise_time.isoformat(), sunrise_t.isoformat()]

        return None

    @property
    def alt_az_pos(self) -> SkyCoord:
        obj_coords = SkyCoord.from_name(self.obj_name)

        return obj_coords.transform_to(AltAz(obstime=self.start_time - self.utc_offset, location=self.geo_loc))

    @property
    def peak_alt(self) -> float:
        loc = self.observer_loc

        peak_iso = loc.target_meridian_transit_time(
            self.start_time, self.target, which='nearest') + timedelta(hours=self.utc_offset)

        obj_coords = SkyCoord.from_name(self.obj_name)

        return obj_coords.transform_to(AltAz(obstime=peak_iso - self.utc_offset, location=self.geo_loc)).alt

    @property
    def suggested_hours(self):

        set_time = self.obj_set_time

        loc = self.observer_loc

        dark_iso = loc.twilight_evening_astronomical(self.start_time)
        dark_time = datetime.fromisoformat(dark_iso.iso)

        if self.peak_alt < 10.0:
            return None
