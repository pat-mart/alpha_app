from datetime import datetime, timedelta

import ephem
from astropy.time import Time

from data.sky_obj import SkyObject


class HelioObj:
    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float)):

        self.target = ephem.Jupiter()  # Placeholder

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

        self.utc_offset_td = timedelta(hours=SkyObject.utc_offset(coords))

        self.sun_always_up = False
        self.sun_always_down = False

        self.target_always_up = False
        self.target_always_down = False

        self.sun = ephem.Sun()

        self.sun.compute(self.observer)
        try:
            self.observer.disallow_circumpolar(ephem.degrees(-HelioObj.to_float(self.sun.dec)))
        except ephem.NeverUpError or ephem.AlwaysUpError:  # Odd workaround because NeverUpError is always returned from PyEphem (bug)
            self.sun_always_up = self.sun.alt >= 0
            self.sun_always_down = not self.sun_always_up

        self.target.compute(self.start_time)
        try:
            self.observer.disallow_circumpolar(self.target.dec)
        except ephem.NeverUpError or ephem.AlwaysUpError:
            self.target_always_up = self.target.alt >= 0

        self.sunrise_t = self.observer.next_rising(ephem.Sun()).datetime().time()
        self.sunset_t = self.observer.next_setting(ephem.Sun()).datetime().time()

        self.obj_rise_t = self.observer.next_rising(self.target).datetime().time()
        self.obj_set_t = self.observer.next_setting(self.target).datetime().time()

    @staticmethod
    def to_float(angle: ephem.Angle) -> float:
        angle = str(angle)
        hours, minutes, seconds = map(float, angle.split(':'))

        degrees = hours + minutes / 60.0 + seconds / 3600.0

        return degrees
    def hours_visible(self):
        pass

    def suggested_hours(self):
        pass

    def peak_alt_az(self):
        pass
