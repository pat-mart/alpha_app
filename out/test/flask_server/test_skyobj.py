import random
import unittest

from astropy.time import Time

from data.sky_obj import SkyObject


class TestSkyObj(unittest.TestCase):

    def test_init(self):
        ran_lat = random.randint(-90, 90)
        ran_lon = random.randint(-180, 180)

        sky_obj = SkyObject(
            start_time=Time('2023-7-15T21:15:31.0'),
            end_time=Time('2023-7-16T01:12:00.0'),
            obj_name="LMC",
            coords=(ran_lat, ran_lon),
        )
        self.assertIsNotNone(sky_obj.suggested_hours)


if __name__ == 'main':
    unittest.main()
