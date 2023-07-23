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

    print(start_time, type(start_time))

    start = Time(start_time)
    end = Time(end_time)

    print(start_time == '2023-7-15T21:15:31.0')

    obj = SkyObject(
        start_time=start,
        end_time=end,
        obj_name=obj_name,
        coords=(float(lat), float(lon))
    )

    obj_data = {
        'Object name': obj.obj_name,
        'Start time': str(obj.start_time.iso),
        'End time': str(obj.end_time.iso),
        'Coordinates': obj.coords,
        'Hours visible': obj.hours_visible,
        'Hours suggested': obj.hours_visible
    }

    return jsonify(obj_data)


@app.route('/')
def hello_world():
    x = SkyObject(
        start_time=Time('2023-7-15T21:15:31.0'),
        end_time=Time('2023-7-16T01:12:00.0'),
        obj_name="LMC",
        coords=(-89, -120),
    )

    return "<h1>Pat</h1>"


if __name__ == '__main__':
    app.run()
