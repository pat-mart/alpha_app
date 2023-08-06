from datetime import datetime, timedelta

import ephem
from astropy.time import Time

from data.obj_util import ObjUtil
from data.sky_obj import SkyObject

"""
Why does this class not extend SkyObject? Because the methods are quite different in their implementations. 
I suppose I could have had them both extend a more generic class, but I thought it would have limited benefit. 
"""


class HelioObj:
    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float)):

        self.target = ephem.Jupiter()  # Placeholder
        self.utc_offset_td = timedelta(hours=ObjUtil.utc_offset(coords))
        self.obj_name = obj_name.lower()

        self.start_astropy_time = start_time
        self.end_astropy_time = end_time

        self.day_vis = obj_name in ['moon', 'sun']

        constructor = getattr(ephem, obj_name.title(), AttributeError)

        if constructor is not AttributeError:
            self.target = constructor()
        else:
            constructor('Planet not found')

        self.start_time = start_time.to_datetime()
        self.end_time = end_time.to_datetime()

        self.start_dt = datetime.combine(self.start_time.date(),(self.start_time - self.utc_offset_td).time())
        self.end_dt = datetime.combine(self.end_time.date(), (self.end_time - self.utc_offset_td).time())

        self.start_dt = self.start_dt.strftime('%Y/%m/%d %H:%M')
        self.end_dt = self.end_dt.strftime('%Y/%m/%d %H:%M')

        self.observer = ephem.Observer()

        self.observer.lat = str(coords[0])
        self.observer.lon = str(coords[1])
        self.observer.date = self.start_dt

        self.obj_name = obj_name

        self.sun_always_up = self.sun_always_down = self.target_always_up = self.target_always_down = False

        self.sun = ephem.Sun()

        self.sun.compute(self.observer)
        try:
            self.observer.disallow_circumpolar(ephem.degrees(ObjUtil.to_float(self.sun.dec)))
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

    @property
    def hours_visible(self) -> [datetime]:
        return ObjUtil.hours_visible(
            target_always_up=self.target_always_up,
            target_always_down=self.target_always_down,
            sun_always_up=self.sun_always_up,
            sun_always_down=self.sun_always_down,
            start_time=self.start_astropy_time,
            end_time=self.end_astropy_time,
            obj_rise_time=self.obj_rise_t,
            obj_set_time=self.obj_set_t,
            sunrise_t=self.sunrise_t,
            sunset_t=self.sunset_t
        )

    @property
    def peak_time(self):
        gmt_time = self.observer.next_transit(self.target, start=self.start_time.date().strftime('%Y/%m/%d')).datetime()

        local_time = gmt_time.strftime('%Y/%m/%d %H:%M')

        return local_time

    @property
    def peak_alt_az(self):
        obs_copy = self.observer.copy()
        obs_copy.date = self.peak_time

        target_copy = self.target

        target_copy.compute(obs_copy)

        print('%s %s' % (target_copy.alt, target_copy.az))

        return {"alt": target_copy.alt, "az": target_copy.az}

    @property
    def suggested_hours(self):
        pass
