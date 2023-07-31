from astropy.time import Time
from flask import Flask, request, jsonify

from data.sky_obj import SkyObject

app = Flask(__name__)


@app.route('/api/search', methods=['GET'])
# example search endpoint:
# api/search?objname=M31&starttime=2023-7-15T21:15:31.0&endtime=2023-7-16T01:12:00.0&lat=10.10&lon=10.10&thresh=20.0
def get_obj_pos():

    args = request.args

    obj_name = args.get('objname')
    start_time = args.get('starttime')
    end_time = args.get('endtime')
    lat = args.get('lat')
    lon = args.get('lon')

    start = Time(start_time)
    end = Time(end_time)

    threshold = float(args.get('thresh'))

    obj = SkyObject(
        start_time=start,
        end_time=end,
        obj_name=obj_name,
        coords=(float(lat), float(lon)),
        threshold=threshold
    )

    if obj.hours_visible[0] != -1:
        str_hrs = [x.isoformat() for x in obj.hours_visible]
    else:
        str_hrs = ['Target is never observable']

    peak_alt_az = obj.peak_alt_az

    obj_data = {
        'obj_name': obj.obj_name,
        'time_start': obj.start_time.iso,
        'time_end': obj.end_time.iso,
        'coords': obj.coords,
        'utc_offset': obj.utc_offset,
        'viewing_hours': {'h_visible': str_hrs, 'h_suggested': obj.suggested_hours},
        'suggest_hours': obj.suggested_hours,
        'peak': {'alt': peak_alt_az[0], 'az': peak_alt_az[1], 'time': obj.peak_time}
    }

    return jsonify(obj_data)


@app.route('/')
def hello_world():

    return "<h1>Pat</h1>"


if __name__ == '__main__':
    app.run()
