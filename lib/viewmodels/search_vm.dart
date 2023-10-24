import 'dart:core';

import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/create_plan_util.dart';
import 'package:astro_planner/models/sky_obj_m.dart';
import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/json_data/skyobj_data.dart';
import '../models/plan_m.dart';

class SearchViewModel extends ChangeNotifier {

  static final SearchViewModel _instance = SearchViewModel._();

  List<SkyObj> resultsList = [];

  List<SkyObjectData?> dataList = [];

  List<SkyObj> _csvData = [];

  final Map<String, Plan?> _infoMap = {};
  final Map<String, SkyObj> _searchMap = {};

  final Map<String, SkyObjectData> _cache = {};
  final Map<String, SkyObj> _results = {};

  String _currentQuery = '';

  LocationViewModel locationVm = LocationViewModel();
  DateTimeViewModel dateTimeVm = DateTimeViewModel();

  bool canUseData = false;

  final Map<int, dynamic> tappedInstance = {};

  SkyObj? previewedResult;
  SkyObj? selectedResult;

  bool canAdd = false;

  SearchViewModel._();

  factory SearchViewModel(){
    return _instance;
  }

  List<SkyObj> get csvData => _csvData;

  Map<String, Plan?> get infoMap => _infoMap;

  Map<String, SkyObjectData> get infoCache => _cache;

  Future<void> loadCsvData() async {
    if (_searchMap.isEmpty) {
      final astroData = await rootBundle.loadString('assets/alpha_astro_data.csv', cache: false);

      List<List<dynamic>> data = const CsvToListConverter().convert(astroData);

      for (List<dynamic> row in data) {
        String key;
        if(row[2] == 'Planet'){
          key = ',${row[0].toString().toUpperCase()}';
        }
        else {
          key = (row[2] != 'Star')
            ? ',${row[0]},${row[1]},${row[5].toString().toUpperCase()}'
            : ',${row[1].toString().toUpperCase()} ${row[3]
            .toUpperCase()},${row[0]},${row[5].toString().toUpperCase()}';
        }
        SkyObj value = SkyObj(
          catalogName: row[0],
          catalogAlias: (row[1] is String && row[1] != '_' || row[2] == 'Planet') ? row[1] : '',
          objType: row[2],
          constellation: row[3],
          magnitude: (row[4] is num) ? row[4] : double.nan,
          properName: (row[2] == 'Planet') ? row[0] : row[5],
          isStar: (row[2] == 'Star')
        );
        _searchMap[key] = value;
      }
    }
    _csvData = _searchMap.values.toList();
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

  Map<String, SkyObj> _filteredResults (String query) {

    final List<String> keysToRemove = [];
    final List<String> dataKeysToRemove = [];

    query = _cleanQuery(query).trim();

    int numRemoved = 0;

    if(query.isEmpty){
      return {};
    }

    var startDt = dateTimeVm.startDateTime ?? DateTime.now();
    var endDt = dateTimeVm.endDateTime ?? DateTime.now().add(const Duration(minutes: 1));

    _searchMap.forEach((key, value) {

      final upper = query.toUpperCase();
      final title = query.toTitle();

      if(key.contains(',$upper') || key.contains(' $upper') || key.contains(',$title') || key.contains(' $title')) {
        if(_results.length < 10 + numRemoved){
          _results[key] = value;

          if(locationVm.lon != null && locationVm.lat != null) {
            _infoMap[key] =
              Plan.fromCsvRow(
                value,
                startDt,
                endDt,
                locationVm.lat!,
                locationVm.lon!
              );
          }
        }
      }
      else {
        if(_results.containsKey(key)) {
          numRemoved++;
          keysToRemove.add(key);
          dataKeysToRemove.add(key);
        }
      }
    });

    for(String key in keysToRemove){
      _results.remove(key);
      _infoMap.remove(key);
    }

    return _results;
  }

  void loadSearchResults(String query) {
    _currentQuery = query;

    resultsList = _filteredResults(_currentQuery).values.toList();

    if(!resultsList.contains(previewedResult)){
      canAdd = false;
      previewedResult = null;
    }

    notifyListeners();
  }

  Future<void> loadSinglePlanData(String uuid) async {
    bool hasInternet = await CreatePlanUtil.hasInternetConnection();

    if(!hasInternet || _infoMap.isEmpty) {
      return;
    }

    final plan = _infoMap[uuid];

    if(plan != null && _cache.containsKey(uuid)){
      dataList.add(_cache[plan.uuid]);
    } else {
      await plan?.getObjInfo();
    }
  }

  /// doNotifyListeners is used to prevent reloading of widgets not currently in context (-> runtime error)
  void clearResults({required bool doNotifyListeners}){
    _currentQuery = '';

    if(selectedResult == null || selectedResult != previewedResult){
      previewedResult = null;
    }
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

  Map<String, SkyObj> get searchMap => _searchMap;
}
