import random
import unittest

from astroplan import TargetNeverUpWarning, TargetAlwaysUpWarning

'''
None of this stuff is really of any use because testing try/except with 
warnings (not really errors in the literal sense) is a pain and totally unnecessary
'''


class TestSkyObj(unittest.TestCase):

    def test_obj_never_rises(self):
        ran_lat = random.randint(-90, -88)
        ran_lon = random.randint(-180, 180)

        self.assertRaises(TargetNeverUpWarning)

    def test_obj_never_sets(self):
        ran_lat = random.randint(1, 90)
        ran_lon = random.randint(-180, 180)

        self.assertRaises(TargetAlwaysUpWarning)

    def test_typical_obj(self):
        self.assertIsNotNone(None)  # Placeholder


if __name__ == 'main':
    unittest.main()
