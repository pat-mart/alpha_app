import sys

from astropy.coordinates import EarthLocation
from astropy.time import Time
from flask import Flask, request
import random

from data.sky_obj import transform_coord

app = Flask(__name__)


@app.route('/api/search', methods=['GET'])
# example search url:
# /search?objname='M31'&startdate=071323&duration=09:21&lat=10.10&long=10.10&elev=10
def get_obj_pos():
    args = request.args

    s_time =
    data = transform_coord()

@app.route('/')
def hello_world():
    print(transform_coord(Time('2023-07-13T21:30:21.0'), 'M31', EarthLocation(lon=-70.1, lat=40.1, height=10)),
          file=sys.stdout)
    return 'Hello World!'


if __name__ == '__main__':
    app.run()
