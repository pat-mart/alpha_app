from dataclasses import dataclass

from astropy.time import Time
from flask import Flask, request, jsonify

import os

from flask_sqlalchemy import SQLAlchemy

from data.geo_coord import GeoCoord
from data.obj_data import transform_coord

app = Flask(__name__)


@app.route('/')
def hello_world():  # put application's code here
    print(transform_coord(Time('21:33:00'), obj_name='M33', geo_coord=GeoCoord(lat=40.8, long=-70.1), elev=10.1))
    return 'Hello World!'


@app.route('/search', methods=['GET'])
def get_obj_data():
    args = request.args.to_dict()


app.app_context().push()
