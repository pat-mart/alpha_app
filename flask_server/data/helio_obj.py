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
    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float), threshold: float):

        self.target = ephem.Jupiter()  # Placeholder
        self.utc_offset_td = timedelta(hours=ObjUtil.utc_offset(coords))
        self.obj_name = obj_name.lower()

        self.start_astropy_time = start_time
        self.end_astropy_time = end_time

        self.threshold = threshold

        constructor = getattr(ephem, obj_name.title(), ephem.Body)

        if constructor is not AttributeError:
            self.target = constructor()
        else:
            AttributeError('Planet not found')

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

        if self.target_always_down:
            return [-1, -1]

        elif self.sun_always_up:
            if self.obj_name == 'sun':
                return [self.start_dt, self.end_dt]
            elif self.obj_name == 'moon':
                return [self.obj_rise_t, self.obj_set_t]
            else:
                return [-1, -1]

        elif self.obj_name in ['sun', 'moon']:
            return [self.obj_rise_t, self.obj_set_t]

        return ObjUtil.hours_visible(
            target_always_up=self.target_always_up,
            target_always_down=self.target_always_down,
            sun_always_up=self.sun_always_up,
            sun_always_down=self.sun_always_down,
            start_time=self.start_astropy_time,
            end_time=self.end_astropy_time,
            obj_rise_time=self.obj_rise_t,
            obj_set_time=self.obj_set_t,
            obs_start=self.sunrise_t,
            obs_end=self.sunset_t
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

        if self.threshold <= -1:
            return [-1]

        start = datetime.combine(self.start_astropy_time.to_datetime().date(), self.hours_visible[0])
        end = datetime.combine(self.end_astropy_time.to_datetime().date(), self.hours_visible[1])

        t_interval = (end - start) / 12

        points = [start + (i * t_interval) for i in range(1, 12)]

        points[-1] = end

        times = []

        times_i = -1

        obs_copy = self.observer.copy()

        for t_point in points:  # Filters times, opted to not use enumerate because times_i = -1

            t = Time(t_point).to_datetime()

            obs_copy.date = t.strftime('%Y/%m/%d %H:%M')

            self.target.compute(obs_copy)
            altitude = obs_copy.alt

            if altitude >= self.threshold:
                if len(times) >= 2 and times[times_i] - t_interval == times[times_i - 1]:  # Ensures no gaps
                    times.append(t_point)
                    times_i += 1
                elif len(times) < 2:
                    times.append(t_point)
                    times_i += 1

        if len(times) < 2:
            return [-1]

        return [times[0].isoformat(), times[-1].isoformat()]
