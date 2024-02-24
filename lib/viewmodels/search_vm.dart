import 'dart:collection';
import 'dart:core';
import 'dart:io';

import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/models/sky_obj_m.dart';
import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/json_data/skyobj_data.dart';

class SearchViewModel extends ChangeNotifier {

  static final SearchViewModel _instance = SearchViewModel._();

  List<SkyObj> resultsList = [];

  List<SkyObjectData?> dataList = [];

  Map<SkyObj, HttpClientRequest> objQueryMap = {};

  final HashSet<SkyObj> _searchList = HashSet<SkyObj>();

  final Map<String, SkyObjectData> _cache = {};
  final HashSet<SkyObj> _results = HashSet<SkyObj>();

  String _currentQuery = '';

  LocationViewModel locationVm = LocationViewModel();
  DateTimeViewModel dateTimeVm = DateTimeViewModel();

  bool canUseData = false;

  SkyObj? previewedResult;
  SkyObj? selectedResult;

  bool canAdd = false;

  SearchViewModel._();

  factory SearchViewModel(){
    return _instance;
  }

  Map<String, SkyObjectData> get infoCache => _cache;

  Future<void> loadCsvData() async {

    if (_searchList.isEmpty) {

      final astroData = await rootBundle.loadString('assets/alpha_data_v2.csv', cache: false);

      List<List<dynamic>> data = const CsvToListConverter().convert(astroData);

      if (data.length == 1) {
        data = const CsvToListConverter().convert(astroData, eol: '\n');
      }

      for (List<dynamic> row in data) {

        SkyObj value = SkyObj(
          catalogName: row[0],
          catalogAlias: (row[4] == 'star' || row[1] is String) ? row[1].toString() : '',
          constellation: row[2],
          magnitude: (row[6] is num) ? row[6] : double.nan,
          properName: (row[3] == 'planet') ? row[0] : row[7],
          isStar: (row[3] == 'star'),
          isPlanet: (row[3] == 'planet'),
          ra: row[4],
          dec: row[5]
        );
        _searchList.add(value);
      }
    }
  }

  String removeProperAlias(String properName){
    if(properName.contains(',')){
      return properName.substring(0, properName.indexOf(','));
    }
    return properName;
  }

  String _cleanQuery(String query){
    return query.replaceAll(',', '');
  }

  Set<SkyObj> _filteredResults (String query) {

    final List<SkyObj> valsToRemove = [];

    query = _cleanQuery(query).trim();

    int numRemoved = 0;

    if(query.isEmpty){
      return {};
    }

    // Realized how to drastically improve this randomly one night as I was falling asleep
    // I think my original concept of map iteration was misguided
    // Behold, linear-ish (time, not sure about space) prefix-based searching

    for (var value in _searchList) {

      final upper = query.toUpperCase();

      var starName = '';

      if(value.isStar && value.catalogAlias != ''){
        starName = (value.catalogAlias + value.constellation).toUpperCase();
      }

      if(value.catalogName.toUpperCase().startsWith(upper) || value.properName.toUpperCase().startsWith(upper) ||
          value.constellation.toUpperCase().startsWith(upper) ||
          value.catalogAlias.toUpperCase().startsWith(upper) ||
          starName.startsWith(upper) ||
          value.properName.toUpperCase().contains(upper)
      ) {
        if(_results.length < 10 + numRemoved && !_results.contains(value)){
          _results.add(value);
        }
      }

      else {
        if(_results.contains(value)) {
          numRemoved++;
          valsToRemove.add(value);
        }
      }
    }

    for(SkyObj obj in valsToRemove){
      _results.remove(obj);
    }

    return _results;
  }

  void loadSearchResults(String query) {

    _currentQuery = query;

    resultsList = _filteredResults(query).toList();

    if(!resultsList.contains(previewedResult)){
      canAdd = false;
      previewedResult = null;
    }

    notifyListeners();
  }

  void cleanInfoCache(bool didChangeFilter, SkyObjectData instance, String catalogName){
    if(infoCache[catalogName] == instance || didChangeFilter){
      infoCache.remove(catalogName);
    }
  }

  void cancelDeadRequests() {
    List<dynamic> keysToRemove = [];
    objQueryMap.forEach((key, value) {
      if(!resultsList.contains(key) && !infoCache.containsValue(value)){
        value.abort();
        keysToRemove.add(key);
      }
    });

    for(var key in keysToRemove){
      objQueryMap.remove(key);
    }
  }

  /// doNotifyListeners is used to prevent reloading of widgets not currently in context (-> runtime error)
  void clearResults({required bool doNotifyListeners}){
    _currentQuery = '';

    resultsList.clear();

    if(doNotifyListeners){
      notifyListeners();
    }
  }

  void selectResult(){

    selectedResult = previewedResult;
    previewedResult = null;

    notifyListeners();
  }

  void previewResult(SkyObj row){
    previewedResult = row;
    canAdd = true;

    notifyListeners();
  }

  void deselectResult(SkyObj row){
    previewedResult = null;
    canAdd = false;

    notifyListeners();
  }

  HashSet<SkyObj> get searchList => _searchList;
}
