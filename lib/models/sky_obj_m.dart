import 'dart:convert';
import 'dart:core';

import 'package:astro_planner/util/enums/catalog_types.dart';

import '../util/plan/catalog_name.dart';
import 'json_data/skyobj_data.dart';
import 'package:http/http.dart' as http;

class SkyObject {

  String _customCatName = '';

  late String _name;

  late CatalogName _catName;

  double _magnitude = 0;

  String _ipAddress = '';

  SkyObject(this._name, this._catName, [this._magnitude=0]);

  SkyObject.customCatalogName(this._name, this._customCatName, [this._magnitude=0]);

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

  Future<SkyObjectData> getObjData() async{
    var url = Uri.parse('');

    final response = await http.get(url);

    if(response.statusCode == 200){
      return SkyObjectData.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load sky object data');
  }
}
