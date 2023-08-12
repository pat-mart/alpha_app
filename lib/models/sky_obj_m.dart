import 'dart:convert';
import 'dart:core';

import 'package:astro_planner/models/plan_m.dart';
import 'package:astro_planner/util/enums/catalog_types.dart';
import 'package:intl/intl.dart';

import '../util/plan/catalog_name.dart';
import '../util/plan/csv_row.dart';
import 'json_data/skyobj_data.dart';
import 'package:http/http.dart' as http;

class SkyObject {

  String _customCatName = '';

  String _name = '';

  CatalogName _catName = CatalogName.none();

  num _magnitude = 0;

  SkyObject(this._name, this._catName, [this._magnitude=0]);

  SkyObject.customCatalogName(this._name, this._customCatName, [this._magnitude=0]);

  SkyObject.fromCatalogName(this._catName){
    _name = _catName.toString();
  }

  SkyObject.fromCsvRow(CsvRow row){
    _name = row.properName;
    _customCatName = row.catalogName;
    _magnitude = row.magnitude;
  }

  String get name => _name;

  num get magnitude => _magnitude;

  String getFormattedCatalogName() {
    if(_customCatName != ''){
      return _customCatName;
    }
    else if(_catName.type != CatalogTypes.messier){
      return '${_catName.type.asTitleized()} ${_catName.num}';
    }
    return '${_catName.type.asUppercase()} ${_catName.num}';
  }
}
