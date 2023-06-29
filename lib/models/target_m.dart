import 'dart:core';

import 'package:astro_planner/util/enums/catalog_types.dart';
import 'package:http/http.dart' as http;

import '../util/plan/catalog_name.dart';

class SkyObject {

  late String _name;

  late CatalogName _catName;

  double _magnitude = 0;

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
