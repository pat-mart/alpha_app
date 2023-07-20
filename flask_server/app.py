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
        start_time=Time('2023-7-15T21:15:31.0'),
        end_time=Time('2023-7-16T01:12:00.0'),
        obj_name="LMC",
        coords=(89.9, -73.1),
    )

    return "<h1>{{sky_obj.}}</h1>"


if __name__ == '__main__':
    app.run()
