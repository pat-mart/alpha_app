from datetime import timedelta

import ephem
from astropy.time import Time

from data.sky_obj import SkyObject


class HelioObj:
    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float)):

        constructor = getattr(ephem, obj_name.title(), AttributeError)
        if constructor is not AttributeError:
            self.target = constructor()
        else:
            constructor('Planet not found')

        self.start_time = start_time.to_datetime().strftime('%Y/%m/%d %H:%M')
        self.end_time = end_time.to_datetime().strftime('%Y/%m/%d %H:%M')

        self.observer = ephem.Observer()

        self.observer.lat = coords[0]
        self.observer.lon = coords[1]
        self.observer.date = self.start_time

        self.obj_name = obj_name

    def hours_visible(self):
        pass

    def suggested_hours(self):
        pass

    def peak_alt_az(self):
        pass
