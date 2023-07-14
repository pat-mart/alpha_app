import datetime
import pytz

from astropy.coordinates import EarthLocation, SkyCoord, AltAz
from astropy.time import Time
from geopy.geocoders import Nominatim


class SkyObject:
    def __init__(self, start_time: Time, obj_name: str, geo_loc: EarthLocation):
        self.start_time = start_time
        self.obj_name = obj_name
        self.geo_loc = geo_loc

    @property
    def utc_offset(self):
        geolocator = Nominatim(user_agent='timezone_app')

        location = geolocator.reverse(f"{self.geo_loc.lat}, {self.geo_loc.lon}")
        timezone = pytz.timezone(location.raw['timezone'])

        # Returns timezone code
        return timezone.utcoffset(pytz.utc.localize(datetime.datetime.utcnow())).total_seconds() // 3600

    @property
    def hours_visible(self) -> Time:
        return self.pos_at_time.time_above_horizon()

    @property
    def pos_at_time(self) -> SkyCoord:
        obj_coords = SkyCoord.from_name(self.obj_name)

        return obj_coords.transform_to(AltAz(obstime=self.start_time - self.utc_offset, location=self.geo_loc))

    @property
    def suggested_hours(self) -> []:


