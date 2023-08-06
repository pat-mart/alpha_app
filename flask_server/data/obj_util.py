from datetime import datetime

import ephem
import pytz
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
                      obj_set_time: datetime.time, sunrise_t: datetime.time, sunset_t: datetime.time) -> [datetime]:

        if target_always_down or sun_always_up:
            return [-1, -1]

        elif target_always_up and sun_always_down:
            return [start_time.to_datetime().time(), end_time.to_datetime().time()]

        rise_time = obj_rise_time
        set_time = obj_set_time

        rises_before_sunset = rise_time > sunset_t

        if rises_before_sunset and set_time <= sunrise_t:  # Object rises and sets between sunset and sunrise
            return [rise_time, set_time]

        elif rise_time > sunrise_t and set_time >= sunset_t:  # Object rises during day, sets at night
            return [sunset_t, set_time]

        elif rise_time < sunrise_t and set_time <= sunset_t:  # Object rises at night (early morning), sets during day
            return [rise_time, sunrise_t]

        elif not rises_before_sunset and set_time >= sunrise_t:  # Object rises at night (after sunset), sets during day
            return [rise_time, sunrise_t]

        return [-1, -1]

    @staticmethod
    def to_float(angle: ephem.Angle) -> float:
        angle = str(angle)
        hours, minutes, seconds = map(float, angle.split(':'))

        degrees = hours + minutes / 60.0 + seconds / 3600.0

        return degrees
