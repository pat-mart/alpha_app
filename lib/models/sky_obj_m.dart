import 'dart:core';

import 'package:astro_planner/util/enums/catalog_types.dart';

import '../util/plan/catalog_name.dart';

class SkyObject {

  String _customCatName = '';

  late String _name;

  late CatalogName _catName;

  double _magnitude = 0;

  SkyObject(this._name, this._catName);

  SkyObject.customCatalogName(this._name, this._customCatName);

  SkyObject.fromCatalogName(this._catName){
    _name = _catName.toString();
  }

  String get name => _name;

  double get magnitude => _magnitude;

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
