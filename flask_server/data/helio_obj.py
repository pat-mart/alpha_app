from astropy.time import Time
from astropy.coordinates import solar_system_ephemeris, EarthLocation
from astropy.coordinates import get_body_barycentric, get_body

from data.sky_obj import SkyObject


class HelioObject(SkyObject):
    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float)):
        super().__init__(start_time, end_time, obj_name, coords)

        self.obj_name = obj_name.lower()

        if self.obj_name not in ['sun', 'moon', 'venus']:
            self.is_day_vis = False


