from datetime import datetime

import ephem
import pytz
import astropy.units as u
from astropy.time import Time
from timezonefinder import TimezoneFinder


class ObjUtil:
    @staticmethod
    def loc_utc_str(coords: (float, float)):
        tz_str = TimezoneFinder().timezone_at(lat=coords[0], lng=coords[1])
        return pytz.timezone(tz_str)

    @staticmethod
    def utc_offset(coords: (float, float)) -> float:
        timezone = ObjUtil.loc_utc_str((coords[0], coords[1]))
        return timezone.utcoffset(datetime.now()).total_seconds() // 3600

    @staticmethod
    def hours_visible(target_always_down: bool, target_always_up: bool, sun_always_down: bool,
                      sun_always_up: bool, start_time: Time, end_time: Time, obj_rise_time: datetime.time,
                      obj_set_time: datetime.time, morn_twi: datetime.time, even_twi: datetime.time) -> [datetime]:

        if target_always_down or sun_always_up or even_twi is None or morn_twi is None:
            return [-1, -1]

        elif target_always_up and sun_always_down:
            return [start_time.to_datetime().time(), end_time.to_datetime().time()]

        rise_time = obj_rise_time
        set_time = obj_set_time

        morn_twi = morn_twi.time()  # Can be interpreted as evening twilight
        even_twi = even_twi.time()  # Can be interpreted as morning

        if morn_twi <= rise_time <= set_time <= even_twi:
            return [-1, -1]

        elif set_time <= rise_time <= morn_twi:  # Target rises before "sunrise", after "sunset"
            return [[rise_time, morn_twi], [even_twi, set_time]]

        elif rise_time <= morn_twi and set_time <= even_twi:
            return [rise_time, morn_twi]

        elif even_twi >= rise_time >= morn_twi >= set_time:
            return [even_twi, set_time]

        elif rise_time >= even_twi and set_time <= morn_twi:
            return [rise_time, set_time]

        elif rise_time >= even_twi and set_time >= morn_twi:
            return [rise_time, morn_twi]

        elif rise_time <= even_twi and set_time >= morn_twi:
            return [even_twi, morn_twi]

        return [-1, -1]

    @staticmethod
    def to_float(angle: ephem.Angle) -> float:
        angle = str(angle)
        hours, minutes, seconds = map(float, angle.split(':'))

        degrees = hours + minutes / 60.0 + seconds / 3600.0

        return degrees

    @staticmethod
    def needs_mer_flip(hours_visible: [datetime], peak_time: str, peak_alt: u.deg):
        if hours_visible[0] == -1 or peak_alt.value <= 87.0:
            return False

        dt = datetime.fromisoformat(peak_time)

        peaks_during_observation = hours_visible[0] <= dt.time() <= hours_visible[1]

        return peaks_during_observation
