import 'dart:core';

import 'package:astro_planner/util/catalog_types.dart';
import 'package:http/http.dart' as http;

import '../util/catalog_name.dart';

class SkyObject {

  double _magnitude = 0;

  late String _name;

  late CatalogName _catName;

  SkyObject(this._name, this._catName);

  SkyObject.fromCatalogName(this._catName){
    _name = _catName.toString();
  }

  String get name => _name;

  double get magnitude => _magnitude;

  String getFormattedCatalogName() {
    return '${_catName.type.asString()} ${_catName.num}';
  }

  Future<http.Response> getApiData() async {
    return http.get(Uri());
  }
}
