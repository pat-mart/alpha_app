from astropy.time import Time
from flask import Flask, request, jsonify

from data.helio_obj import HelioObj
from data.obj_util import ObjUtil
from data.sky_obj import SkyObject

app = Flask(__name__)


@app.route('/api/search/helio', methods=['GET'])
def get_heliocentric_pos():
    args = request.args

    lat = args.get('lat')
    lon = args.get('lon')

    obj = HelioObj(
        start_time=Time('2023-8-3T18:15:31.0'),
        end_time=Time('2023-8-4T03:15:31.0'),
        obj_name='Mars',
        coords=(40.8, -73)
    )

    return "<h1>Mone</h1>"
@app.route('/api/search', methods=['GET'])
# example search endpoint:
# /api/search?objname=M31&starttime=2023-8-2T21:15:31.0&endtime=2023-8-3T01:12:00.0&lat=10.10&lon=10.10&thresh=20.0
def get_obj_pos():
    args = request.args

    obj_name = args.get('objname').lower()
    start_time = args.get('starttime')
    end_time = args.get('endtime')
    lat = args.get('lat')
    lon = args.get('lon')

    start = Time(start_time)
    end = Time(end_time)

    threshold = float(args.get('thresh'))

    if obj_name in ['mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune']:
        obj = HelioObj(
            start_time=start,
            end_time=end,
            obj_name=obj_name,
            coords=(float(lat), float(lat)),
            threshold=threshold
        )

        start_time = obj.start_time
        end_time = obj.end_time

        peak_alt = obj.peak_alt_az['alt']
        peak_az = obj.peak_alt_az['az']

    else:
        obj = SkyObject(
            start_time=start,
            end_time=end,
            obj_name=obj_name,
            coords=(float(lat), float(lon)),
            threshold=threshold
        )

        start_time = obj.start_time.iso
        end_time = obj.end_time.iso

    peak = obj.peak_alt_az

    if obj.hours_visible[0] != -1:
        str_hrs = [x.isoformat() for x in obj.hours_visible]
    else:
        str_hrs = ['Target is never observable']

    obj_data = {
        'obj_name': obj.obj_name,
        'time_start': start_time,
        'time_end': end_time,
        'coords': obj.coords,
        'utc_offset': ObjUtil.utc_offset(obj.coords),
        'viewing_hours': {'h_visible': str_hrs, 'h_suggested': obj.suggested_hours},
        'peak': {'alt': peak['alt'].value, 'az': peak['az'].value, 'time': str(obj.peak_time)},
        'mer_flip': int(obj.needs_mer_flip)
    }

    return jsonify(obj_data)


@app.route('/')
def hello_world():

    return "<h1>Pat</h1>"


if __name__ == '__main__':
    app.run()
