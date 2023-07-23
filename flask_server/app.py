from astropy.time import Time
from flask import Flask, request

from data.sky_obj import SkyObject

app = Flask(__name__)


@app.route('/api/search', methods=['GET'])
# example search url:
# /search?objname='M31'&starttime=071323T21:30:21&endtime=071323T22:30:21&lat=10.10&long=10.10&
def get_obj_pos():
    args = request.args


@app.route('/')
def hello_world():

    x = SkyObject(
        start_time=Time('2023-7-15T21:15:31.0'),
        end_time=Time('2023-7-16T01:12:00.0'),
        obj_name="LMC",
        coords=(-89, -120),
    )

    print(x.suggested_hours)

    return "<h1>Pat</h1>"

if __name__ == '__main__':
    app.run()
