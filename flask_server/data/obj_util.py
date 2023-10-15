import math
from datetime import datetime, timedelta

import ephem
import pytz
import astropy.units as u
from astropy.coordinates import AltAz, SkyCoord, EarthLocation
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

        elif set_time <= rise_time <= morn_twi:  # Target rises before "sunrise", after "sunset" (rarely happens)
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
    def suggested_hours(coords,az_min: float, az_max: float, alt_threshold: float, start_time: datetime, end_time: datetime,
                        ra_rad: float, dec_rad: float,
                        peak_time: datetime, hours_visible: [datetime]) -> [datetime]:
        az_start = az_end = -1
        alt_start = alt_end = -1

        if alt_threshold <= 0 or hours_visible[0] == -1 or az_max > 360 or az_max <= 0 \
                or az_max < az_min or az_min <= 0:
            return [-1]

        k_deg_to_rad = math.pi/180

        numer = math.sin(alt_threshold * k_deg_to_rad) - (math.sin(coords[0] * k_deg_to_rad) * math.sin(dec_rad))
        denom = math.cos(coords[0] * k_deg_to_rad) * math.cos(dec_rad)

        if not abs(numer/denom) > 1:
            lha = math.acos(numer/denom) * 3.8197  # LHA in hour angles

            lha_td = timedelta(hours=lha)

            alt_start = peak_time - lha_td
            alt_end = peak_time + lha_td

        if az_min > 0 and az_max < 360:
            obj_coord = SkyCoord(ra=ra_rad * (180/math.pi) * u.deg, dec=dec_rad * (180/math.pi) * u.deg, frame="icrs")

            location = EarthLocation.from_geodetic(lon=coords[1], lat=coords[0])

            td = timedelta(hours = ObjUtil.utc_offset(coords))

            time_i = (end_time - start_time) / 40

            print(start_time + td)

            for i in range(40):

                if i == 39:
                    time = end_time + td
                else:
                    time = start_time + (time_i * i) + td

                altaz_coord = obj_coord.transform_to(AltAz(obstime=time, location=location))

                if az_min < (altaz_coord.az * u.deg).value < az_max and (altaz_coord.alt * u.deg).value > 0:
                    if az_start == -1:
                        az_start = time
                    else:
                        az_end = time

        if alt_start == alt_end == az_start == az_end == -1:
            return [-1, -1]

        elif alt_start != -1 and alt_end != -1 and (az_start == -1 or az_end == -1):
            return [alt_start, alt_end]

        elif az_start != -1 and az_end != -1 and (alt_start == -1 or alt_end == -1):
            return [az_start, az_end]

        return [max(alt_start, az_start), max(alt_end, az_end)]


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
