from astropy.time import Time
from flask import Flask, request, jsonify

from data.helio_obj import HelioObj
from data.obj_util import ObjUtil
from data.sky_obj import SkyObject

application = app = Flask(__name__)


@app.route('/api/search', methods=['GET'])
# example search endpoint:
# /api/search?objname=M31&starttime=2023-8-2T21:15:31.0&endtime=2023-8-3T01:12:00.0&lat=10.10&lon=10.10&altthresh=20.0&azmin=0.0
def get_obj_pos():
    args = request.args

    obj_name = args.get('objname').lower()
    start_time = args.get('starttime')
    end_time = args.get('endtime')
    lat = args.get('lat')
    lon = args.get('lon')

    start = Time(start_time)
    end = Time(end_time)

    alt_threshold = float(args.get('altthresh'))
    az_min = float(args.get('azmin'))

    if obj_name in ['mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune']:
        obj = HelioObj(
            start_time=start,
            end_time=end,
            obj_name=obj_name,
            coords=(float(lat), float(lon)),
            alt_threshold=alt_threshold,
            az_min=az_min
        )

        start_time = obj.start_time.isoformat()
        end_time = obj.end_time.isoformat()

        rise_t = obj.obj_rise_t
        set_t = obj.obj_set_t

        peak_t = obj.peak_time

    else:
        obj = SkyObject(
            start_time=start,
            end_time=end,
            obj_name=obj_name,
            coords=(float(lat), float(lon)),
            alt_threshold=alt_threshold,
            az_min=az_min
        )

        start_time = obj.start_time.iso
        end_time = obj.end_time.iso

        rise_t = obj.rise_iso.iso
        set_t = obj.set_iso.iso

        peak_t = obj.peak_time.iso

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
        'viewing_hours': {
            'h_visible': str_hrs,
            'h_suggested': obj.suggested_hours,
            'obj_rise': str(rise_t),
            'obj_set': str(set_t),
            'sunrise': obj.sunrise_t.isoformat(),
            'sunset': obj.sunset_t.isoformat()
        },
        'peak': {'alt': round(peak['alt'].value, 2), 'az': peak['az'].value, 'time': str(peak_t)},
        'mer_flip': int(obj.needs_mer_flip)
    }

    return jsonify(obj_data)


@app.route('/')
def hello_world():

    mars = HelioObj(
        start_time=Time.now(),
        end_time=Time.now(),
        obj_name='mars',
        coords=(40.8, -73.1),
        alt_threshold=32,
        az_min=12,
        az_max=200
    )

    print(mars.suggested_hours)

    return "<h1></h1>"


if __name__ == '__main__':
    application.debug = True
    application.run()
