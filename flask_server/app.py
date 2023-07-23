from astropy.time import Time
from flask import Flask, request, jsonify

from data.sky_obj import SkyObject

app = Flask(__name__)


@app.route('/api/search', methods=['GET'])
# example search endpoint:
# api/search?objname=M31&starttime=2023-7-15T21:15:31.0&endtime=2023-7-16T01:12:00.0&lat=10.10&lon=10.10
def get_obj_pos():
    args = request.args

    obj_name = args.get('objname')
    start_time = args.get('starttime')
    end_time = args.get('endtime')
    lat = args.get('lat')
    lon = args.get('lon')

    start = Time(start_time)
    end = Time(end_time)

    obj = SkyObject(
        start_time=start,
        end_time=end,
        obj_name=obj_name,
        coords=(float(lat), float(lon))
    )

    if obj.hours_visible[0] != -1:
        str_hrs = [x.isoformat() for x in obj.hours_visible]
    else:
        str_hrs = ['Target is never observable']

    obj_data = {
        'Object name': obj.obj_name,
        'Start time': obj.start_time.iso,
        'End time': obj.end_time.iso,
        'Coordinates': obj.coords,
        'UTC offset': obj.utc_offset,
        'Hours visible': str_hrs,
        'Hours suggested': obj.suggested_hours
    }

    return jsonify(obj_data)


@app.route('/')
def hello_world():

    return "<h1>Pat</h1>"


if __name__ == '__main__':
    app.run(threaded=True)
