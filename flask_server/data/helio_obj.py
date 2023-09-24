import math
from datetime import datetime, timedelta

import astropy.time
import astropy.units as u
import ephem
from astropy.coordinates import Angle, EarthLocation
from astropy.time import Time

from data.obj_util import ObjUtil

"""
Why does this class not extend SkyObject? Because the methods are quite different in their implementations. 
I suppose I could have had them both extend a more generic class, but I thought it would have limited benefit. 
"""


class HelioObj:
    def __init__(self, start_time: Time, end_time: Time, obj_name: str, coords: (float, float),
                 alt_threshold: float, az_min: float, az_max: float):

        self.target = ephem.Jupiter()  # Placeholder
        self.utc_offset_td = timedelta(hours=ObjUtil.utc_offset(coords))
        self.obj_name = obj_name.lower()

        self.start_astropy_time = start_time
        self.end_astropy_time = end_time

        self.alt_threshold = alt_threshold
        self.az_min = az_min
        self.az_max = az_max

        self.coords = coords

        constructor = getattr(ephem, obj_name.title(), ephem.Body)

        if constructor is not AttributeError:
            self.target = constructor()
        else:
            AttributeError('Planet not found')

        self.start_time = start_time.to_datetime()
        self.end_time = end_time.to_datetime()

        self.start_dt = datetime.combine(self.start_time.date(), (self.start_time + self.utc_offset_td).time())
        self.end_dt = datetime.combine(self.end_time.date(), (self.end_time + self.utc_offset_td).time())

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
            self.observer.disallow_circumpolar(self.sun.dec)
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
            self.sunrise_t = (self.observer.next_rising(self.sun).datetime() + self.utc_offset_td).time()

            self.observer.date = self.end_dt
            self.target.compute(self.observer)

            self.sunset_t = (self.observer.next_setting(self.sun).datetime() + self.utc_offset_td).time()

        if not (self.target_always_up or self.target_always_down):
            self.obj_rise_t = (self.observer.next_rising(self.target).datetime() + self.utc_offset_td).time()

            self.observer.date = self.end_dt
            self.target.compute(self.observer)

            self.obj_set_t = (self.observer.next_setting(self.target).datetime() + self.utc_offset_td).time()

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
            morn_twi=datetime.combine(self.start_time.date(), self.sunrise_t),
            even_twi=datetime.combine(self.end_time.date(), self.sunset_t)
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

        return {"alt": Angle(f'{target_copy.alt} degrees'), "az": Angle(f'{target_copy.az} degrees')}

    @property
    def suggested_hours(self) -> [datetime]:

        """
        This is similar to the one in SkyObj but has enough operational distinction to be justifiable IMO
        :return: The suggested hours as defined by the degree threshold
        """

        if self.alt_threshold <= 0 or self.az_min <= 0 or self.hours_visible[0] == -1:
            return [-1]

        if self.hours_visible[1] >= self.hours_visible[0] and not self.target_always_up:
            start_day = self.end_astropy_time.to_datetime().date()
        else:
            start_day = self.start_astropy_time.to_datetime().date()

        start = datetime.combine(start_day, self.hours_visible[0])
        end = datetime.combine(self.end_astropy_time.to_datetime().date(), self.hours_visible[1])

        lst = Time(datetime.utcnow()).sidereal_time('mean', longitude=self.coords[1])

        lst = (lst * u.deg).value * (15 * math.pi/180)

        ra = float(repr(self.target.g_ra))

        print(lst)

        lha = lst - ra

        print(lha)

        return [-1, -1]

        # ha = lst.to_datetime() - timedelta(hours=datetime.strptime(self.target.g_ra).hour)
        #
        # peak = self.peak_time
        #
        # if(ha < )


    @property
    def needs_mer_flip(self) -> bool:
        return ObjUtil.needs_mer_flip(
            hours_visible=self.hours_visible,
            peak_time=self.peak_time,
            peak_alt=self.peak_alt_az['alt']
        )
