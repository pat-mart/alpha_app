import random
import unittest

from astroplan import TargetNeverUpWarning, TargetAlwaysUpWarning
from astropy.time import Time

from data.sky_obj import SkyObject


class TestSkyObj(unittest.TestCase):

    def test_obj_never_rises(self):
        ran_lat = random.randint(-90, -88)
        ran_lon = random.randint(-180, 180)

        self.assertRaises(TargetNeverUpWarning)

        x = SkyObject(
            start_time=Time('2023-7-15T21:15:31.0'),
            end_time=Time('2023-7-16T01:12:00.0'),
            obj_name="Polaris",
            coords=(ran_lat, ran_lon),
            alt_threshold= -1,
            az_threshold= -1
        )

    def test_obj_never_sets(self):
        ran_lat = random.randint(1, 90)
        ran_lon = random.randint(-180, 180)

        self.assertRaises(TargetAlwaysUpWarning)

        x = SkyObject(
            start_time=Time('2023-7-15T21:15:31.0'),
            end_time=Time('2023-7-16T01:12:00.0'),
            obj_name="Polaris",
            coords=(ran_lat, ran_lon),
            threshold=20
        )

    def test_typical_obj(self):
        self.assertIsNotNone(
            SkyObject(
                start_time=Time('2023-7-15T21:15:31.0'),
                end_time=Time('2023-7-16T01:12:00.0'),
                obj_name="M31",
                coords=(35, -70),
                threshold=15
            ).suggested_hours
        )


if __name__ == 'main':
    unittest.main()
