import 'dart:core';

import 'package:astro_planner/util/enums/catalog_types.dart';

import '../util/plan/catalog_name.dart';
import '../util/plan/csv_row.dart';

class SkyObject {

  String _customCatName = '';

  String _name = '';

  String _constellation = '';

  CatalogName _catName = CatalogName.none();

  num _magnitude = 0;

  SkyObject(this._name, this._catName, this._constellation, [this._magnitude=double.nan]);

  SkyObject.customCatalogName(this._name, this._customCatName, [this._magnitude=double.nan]);

  SkyObject.fromCatalogName(this._catName){
    _name = _catName.toString();
  }

  SkyObject.fromCsvRow(CsvRow row){
    _name = row.properName;
    _customCatName = row.catalogName;
    _magnitude = row.magnitude;
    _constellation = row.constellation;
  }

  String get name => _name;

  String get catName => _customCatName;

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
