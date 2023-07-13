from astropy.coordinates import EarthLocation, SkyCoord, AltAz
from astropy import units
from astropy.time import Time

from data.geo_coord import GeoCoord
from data.ra_coord import RightAscensionCoord


def transform_coord(start_time: Time, obj_name: str, geo_coord: GeoCoord, elev: float):
    location = EarthLocation.from_geodetic(geo_coord.lat, geo_coord.long, elev * units.m)
    obj_coords = SkyCoord.from_name(obj_name, frame=location)

    return obj_coords.transform_to(AltAz(obstime=start_time, location=location))




