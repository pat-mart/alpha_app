from astropy.time import Time


class RightAscensionCoord:
    def __init__(self, ra: Time, dec: float):
        self.ra = ra
        self.dec = dec

    @property
    def formatted_ra(self):
        return self.ra.strftime('%H:%M:%S')

