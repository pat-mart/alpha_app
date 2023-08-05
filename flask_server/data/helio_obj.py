from datetime import datetime, timedelta

import ephem
from astropy.time import Time

from data.sky_obj import SkyObject


class HelioObj:
    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float)):

        self.target = ephem.Jupiter()  # Placeholder
        self.utc_offset_td = timedelta(hours=SkyObject.utc_offset(coords))
        self.obj_name = obj_name.lower()

        self.day_vis = obj_name in ['moon', 'sun']

        constructor = getattr(ephem, obj_name.title(), AttributeError)

        if constructor is not AttributeError:
            self.target = constructor()
        else:
            constructor('Planet not found')

        self.start_time = start_time.to_datetime()
        self.end_time = end_time.to_datetime()

        self.start_dt = datetime.combine(start_time.to_datetime().date(), (start_time - self.utc_offset_td).to_datetime().time())
        self.end_dt = datetime.combine(end_time.to_datetime().date(), (end_time - self.utc_offset_td).to_datetime().time())

        self.start_dt = self.start_dt.strftime('%Y/%m/%d %H:%M')
        self.end_dt = self.end_dt.strftime('%Y/%m/%d %H:%M')

        self.observer = ephem.Observer()

        self.observer.lat = str(coords[0])
        self.observer.lon = str(coords[1])
        self.observer.date = self.start_dt

        self.obj_name = obj_name

        self.sun_always_up = False
        self.sun_always_down = False

        self.target_always_up = False
        self.target_always_down = False

        self.sun = ephem.Sun()

        self.sun.compute(self.observer)
        try:
            self.observer.disallow_circumpolar(ephem.degrees(HelioObj.to_float(self.sun.dec)))
        except ephem.NeverUpError or ephem.AlwaysUpError:
            # Odd workaround because NeverUpError is always returned from PyEphem (bug)
            self.sun_always_up = self.sun.alt >= 0
            self.sun_always_down = not self.sun_always_up

        self.target.compute(self.observer)
        try:
            self.observer.disallow_circumpolar(self.target.dec)
        except ephem.NeverUpError or ephem.AlwaysUpError:
            self.target_always_up = self.target.alt >= 0
            self.target_always_down = not self.target_always_up

        if not (self.sun_always_up or self.sun_always_down):
            self.sunrise_t = self.observer.next_rising(self.sun).datetime().time()
            self.sunset_t = self.observer.next_setting(self.sun).datetime().time()

        if not (self.target_always_up or self.target_always_down):
            self.obj_rise_t = self.observer.next_rising(self.target).datetime().time()
            self.obj_set_t = self.observer.next_setting(self.target).datetime().time()

    @staticmethod
    def to_float(angle: ephem.Angle) -> float:
        angle = str(angle)
        hours, minutes, seconds = map(float, angle.split(':'))

        degrees = hours + minutes / 60.0 + seconds / 3600.0

        return degrees

    def hours_visible(self) -> [datetime] or [int]:

        if (self.sun_always_up and not self.day_vis) or self.target_always_down:
            return [-1, -1]

        elif self.target_always_up and self.sun_always_down:
            return [self.start_time.time(), self.end_time.time()]

    def suggested_hours(self):
        pass

    def peak_alt_az(self):
        pass
