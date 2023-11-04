from astropy.time import Time
from flask import Flask, request, json, jsonify, make_response, render_template

from data.helio_obj import HelioObj
from data.obj_util import ObjUtil
from data.sky_obj import SkyObject

import gzip

application = app = Flask(__name__)


@app.route('/api/search', methods=['GET'])
# example query:
# /api/search?objname=M31&starttime=2023-8-2T21:15:31.0&endtime=2023-8-3T01:12:00.0&lat=10.10&lon=10.10&altthresh=20.0&azmin=-1&azmax=-1
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
    az_max = float(args.get('azmax'))

    if obj_name in ['mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'moon', 'sun']:
        obj = HelioObj(
            start_time=start,
            end_time=end,
            obj_name=obj_name,
            coords=(float(lat), float(lon)),
            alt_threshold=alt_threshold,
            az_min=az_min,
            az_max=az_max
        )

    else:
        obj = SkyObject(
            start_time=start,
            end_time=end,
            obj_name=obj_name,
            coords=(float(lat), float(lon)),
            alt_threshold=alt_threshold,
            az_min=az_min,
            az_max=az_max
        )

    rise_t = -1
    set_t = -1
    peak_t = -1
    peak_altaz = -1

    sunrise = -1
    sunset = -1

    if hasattr(obj, 'obj_rise_t'):
        rise_t = str(obj.obj_rise_t)

    if hasattr(obj, 'obj_set_t'):
        set_t = str(obj.obj_set_t)

    if hasattr(obj, 'peak_time'):
        if hasattr(obj.peak_time, 'iso'):
            peak_t = obj.peak_time.iso
        else:
            peak_t = obj.peak_time

        peak_altaz = obj.peak_alt_az

    if obj.sunrise_t is not None:
        sunrise = obj.sunrise_t.isoformat()

    if obj.sunset_t is not None:
        sunset = obj.sunset_t.isoformat()

    if obj.hours_visible[0] != -1:
        str_hrs = [x.isoformat() for x in obj.hours_visible]
    else:
        str_hrs = [-1]

    print(rise_t)

    obj_data = {
        'obj_name': obj.obj_name,
        'coords': obj.coords,
        'utc_offset': ObjUtil.utc_offset(obj.coords),
        'target_always_up': obj.target_always_up,
        'target_always_down': obj.target_always_down,
        'viewing_hours': {
            'h_visible': str_hrs,
            'h_suggested': obj.suggested_hours,
            'obj_rise': str(rise_t) if type(rise_t) == str else rise_t,
            'obj_set': str(set_t) if type(set_t) == str else set_t,
            'sunrise': sunrise,
            'sunset': sunset
        },
        'peak': {'alt': round(peak_altaz['alt'].value, 2), 'az': peak_altaz['az'].value, 'time': str(peak_t)},
        'mer_flip': int(obj.needs_mer_flip)
    }

    compressed_json = gzip.compress(json.dumps(obj_data).encode('utf-8'), 8)
    response = make_response(compressed_json)
    response.headers['Content-Length'] = len(compressed_json)
    response.headers['Content-Encoding'] = 'gzip'

    return jsonify(obj_data)


@app.route('/')
def hello_world():
    return "<h1></h1>"

@app.route('/support')
def support_tab():
    return render_template('support.html')

@app.route('/privacy-policy')
def privacy_policy():
    return render_template('privpol.html')

@app.route('/healthcheck')
def health_check():
    return "<h1></h1>"


if __name__ == '__main__':
    application.debug = True
    application.run()
