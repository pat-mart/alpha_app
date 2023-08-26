import 'dart:core';

import 'package:astro_planner/util/enums/catalog_types.dart';

import '../util/plan/catalog_name.dart';
import '../util/plan/csv_row.dart';

class SkyObject {

  String _customCatName = '';

  String _properName = '';

  String _constellation = '';

  CatalogName _catName = CatalogName.none();

  num _magnitude = 0;

  SkyObject(this._properName, this._catName, this._constellation, [this._magnitude=double.nan]);

  SkyObject.customCatalogName(this._properName, this._customCatName, [this._magnitude=double.nan]);

  SkyObject.fromCatalogName(this._catName){
    _properName = _catName.toString();
  }

  SkyObject.fromCsvRow(CsvRow row){
    _properName = row.properName;
    _customCatName = row.catalogName;
    _magnitude = row.magnitude;
    _constellation = row.constellation;
  }

  String get name => _properName;

  String get catName => _customCatName;

  String get constellation => _constellation;

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
