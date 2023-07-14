import sys

from astropy.coordinates import EarthLocation
from astropy.time import Time
from flask import Flask, request

from data.sky_obj import SkyObject

app = Flask(__name__)


@app.route('/api/search', methods=['GET'])
# example search url:
# /search?objname='M31'&startdate=071323&duration=09:21&lat=10.10&long=10.10&elev=10
def get_obj_pos():
    args = request.args


@app.route('/')
def hello_world():
    sky_obj = SkyObject(
        start_time=Time('2023-7-14T14:15:31.0'),
        obj_name="M42",
        coords=(40.08, -70.1),
        elev=10.2
    )

    print(sky_obj.hours_visible, file=sys.stdout)

    return 'Hello World!'


if __name__ == '__main__':
    app.run()
