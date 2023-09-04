import 'dart:core';

import '../util/plan/csv_row.dart';

class SkyObject {

  String _customCatName = '';

  String _properName = '';

  String _constellation = '';

  num? _magnitude;

  SkyObject(this._properName, this._customCatName, this._constellation, [this._magnitude=double.nan]);

  SkyObject.custom(this._properName, this._customCatName, [this._magnitude=double.nan]);

  SkyObject.fromCsvRow(CsvRow row){
    _properName = row.properName;
    _customCatName = row.catalogName;
    _magnitude = row.magnitude;
    _constellation = row.constellation;
  }

  factory SkyObject.fromString(String str){
    List<String> list = str.split("*");

    return SkyObject(
      list[0],
      list[1],
      list[2],
      num.tryParse(list[3])
    );
  }

  @override
  String toString() {
    return '$_properName*$_customCatName*$_magnitude*$_constellation';
  }

  String get name => _properName;

  String get catName => _customCatName;

  String get constellation => _constellation;

  num? get magnitude => _magnitude;
}
