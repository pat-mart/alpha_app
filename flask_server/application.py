from datetime import timedelta

from astropy.coordinates.name_resolve import NameResolveError
from astropy.time import Time
from flask import Flask, request, jsonify

from data.helio_obj import HelioObj
from data.obj_util import ObjUtil
from data.sky_obj import SkyObject

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

    if obj_name in ['mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'moon']:
        obj = HelioObj(
            start_time=start,
            end_time=end,
            obj_name=obj_name,
            coords=(float(lat), float(lon)),
            alt_threshold=alt_threshold,
            az_min=az_min,
            az_max=az_max
        )

        start_time = obj.start_time.isoformat()
        end_time = obj.end_time.isoformat()

    else:
        try:
            obj = SkyObject(
                start_time=start,
                end_time=end,
                obj_name=obj_name,
                coords=(float(lat), float(lon)),
                alt_threshold=alt_threshold,
                az_min=az_min,
                az_max=az_max
            )
        except NameResolveError:
            return jsonify({'msg': 'failure'})

        start_time = obj.start_time.iso
        end_time = obj.end_time.iso

    rise_t = -1
    set_t = -1
    peak_t = -1
    peak_altaz = -1

    sunrise = -1
    sunset = -1

    if hasattr(obj, 'rise_iso'):
        rise_t = obj.rise_iso.iso

    if hasattr(obj, 'set_iso'):
        set_t = obj.set_iso.iso

    if hasattr(obj, 'peak_time'):
        peak_t = obj.peak_time.iso
        peak_altaz = obj.peak_alt_az

    if obj.sunrise_t is not None:
        sunrise = obj.sunrise_t.isoformat()

    if obj.sunset_t is not None:
        sunset = obj.sunset_t.isoformat()

    if obj.hours_visible[0] != -1:
        str_hrs = [x.isoformat() for x in obj.hours_visible]
    else:
        str_hrs = [-1]

    obj_data = {
        'msg': 'good',
        'obj_name': obj.obj_name,
        'time_start': start_time,
        'time_end': end_time,
        'coords': obj.coords,
        'utc_offset': ObjUtil.utc_offset(obj.coords),
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

    return jsonify(obj_data)


@app.route('/')
def hello_world():

    mars = SkyObject(
        start_time=Time.now(),
        end_time=Time.now() + timedelta(hours=2),
        obj_name='M31',
        coords=(40.8, -73.1),
        alt_threshold=30,
        az_min=12,
        az_max=200
    )

    print(mars.suggested_hours)

    return "<h1></h1>"


if __name__ == '__main__':
    application.debug = True
    application.run()
