import astropy.units as u
import numpy as np
import pytz

from astropy.coordinates import EarthLocation, SkyCoord, AltAz
from astroplan import Observer, FixedTarget
from astropy.time import Time
from datetime import datetime
from timezonefinder import TimezoneFinder


class SkyObject:
    """ Allows positional measurement of object at certain time, date and location.
    :param start_time: The time at which observation begins
    :param obj_name: The name of the object, in catalog format, e.g. M31 (if not a heliocentric body).
    :param coords: The (latitude, longitude) coordinate pair of the observation site
    :param elev: The elevation of the observation site.
    """

    def __init__(self, start_time: Time, obj_name: str, coords: (float, float), elev: float):
        self.start_time = start_time
        self.obj_name = obj_name
        self.coords = coords
        self.geo_loc = EarthLocation.from_geodetic(coords[0], coords[1], height=elev)

    def utc_str(self):
        tz_str = TimezoneFinder().timezone_at(lat=self.coords[0], lng=self.coords[1])
        return pytz.timezone(tz_str)

    @property
    def utc_offset(self):
        return self.utc_str().utcoffset(datetime.now())

    @property
    def hours_visible(self):
        loc = Observer(latitude=self.coords[0], longitude=self.coords[1], timezone=self.utc_str())
        target = FixedTarget.from_name(self.obj_name)
        time = Time('2023-7-14T21:15:31.0')

        rise_time = loc.target_rise_time(time, target)
        set_time = loc.target_set_time(time, target)

        sunrise = loc.sun_rise_time(time, which='nearest')
        sunset = loc.sun_set_time(time, which='nearest')

        return [
            (rise_time.iso, sunrise.iso),
            (set_time.iso, sunset.iso)
        ]

    @property
    def alt_az_pos(self) -> SkyCoord:
        obj_coords = SkyCoord.from_name(self.obj_name)

        utc_offset = (self.utc_offset.total_seconds() // 3600) * u.hour

        return obj_coords.transform_to(AltAz(obstime=self.start_time - utc_offset, location=self.geo_loc))

    @property
    def hours_suggested(self) -> []:
        return
