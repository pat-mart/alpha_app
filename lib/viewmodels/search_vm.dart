import 'dart:core';

import 'package:astro_planner/util/plan/csv_row.dart';
import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/json_data/skyobj_data.dart';
import '../models/plan_m.dart';

class SearchViewModel extends ChangeNotifier {

  static final SearchViewModel _instance = SearchViewModel._();

  List<CsvRow> resultsList = [];

  List<SkyObjectData?> dataList = [];

  List<CsvRow> _csvData = [];

  final Map<String, Plan?> _infoMap = {};
  final Map<String, CsvRow> _searchMap = {};

  final Map<String, SkyObjectData> _cache = {};
  final Map<String, CsvRow> _results = {};

  String _currentQuery = '';

  CreatePlanViewModel createPlanVm = CreatePlanViewModel();

  bool canUseData = false;

  final Map<int, dynamic> tappedInstance = {};

  CsvRow? selectedResult;
  bool canAdd = false;

  SearchViewModel._();

  factory SearchViewModel(){
    return _instance;
  }

  List<CsvRow> get csvData => _csvData;

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
        CsvRow value = CsvRow(
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

  String _cleanQuery(String query){
    return query.replaceAll(',', '');
  }

  Map<String, CsvRow> _filteredResults (String query) {

    final List<String> keysToRemove = [];
    final List<String> dataKeysToRemove = [];

    query = _cleanQuery(query).trim();

    if(query.isEmpty){
      return {};
    }

    var startDt = createPlanVm.getStartDateTime ?? DateTime.now();
    var endDt = createPlanVm.getEndDateTime ?? DateTime.now().add(const Duration(minutes: 1));

    _searchMap.forEach((key, value) {
      if(key.contains(',${query.toUpperCase()}') || key.contains(' ${query.toUpperCase()}')) {
        if(_results.length < 10){
          _results[key] = value;
          if(createPlanVm.lon != null && createPlanVm.lat != null) {
            _infoMap[key] =
              Plan.fromCsvRow(
                value,
                startDt,
                endDt,
                createPlanVm.lat!,
                createPlanVm.lon!
              );
          }
        }
      }
      else {
        if(_results.containsKey(key)) {
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

    if(!resultsList.contains(selectedResult)){
      selectedResult = null;
      canAdd = false;
    }

    notifyListeners();
  }

  Future<void> loadSinglePlanData(String uuid) async {
    bool hasInternet = await CreatePlanViewModel().hasInternetConnection();

    if(!hasInternet || _infoMap.isEmpty) {
      return;
    }

    var plan = _infoMap[uuid];

    if(plan != null && _cache.containsKey(uuid)){
      dataList.add(_cache[plan.uuid]);
    } else {
      var data = await plan?.getObjInfo();
    }
  }

  // Future<void> loadPlanData() async {
  //   bool hasInternet = await CreatePlanViewModel().hasInternetConnection();
  //
  //   if(hasInternet && _infoMap.values.isNotEmpty){
  //     for(var plan in _infoMap.values){
  //       if(plan != null){
  //         if(_cache.containsKey(plan.uuid)){
  //           dataList.add(_cache[plan.uuid]);
  //         }
  //         else {
  //           var data = await plan.getObjInfo();
  //           dataList.add(data);
  //           _cache[plan.uuid] = data;
  //         }
  //       }
  //       else {
  //         dataList.add(null);
  //       }
  //     }
  //   }
  //   else {
  //     throw Exception('No internet');
  //   }
  //   notifyListeners();
  // }

  /// doNotifyListeners is used to prevent reloading of widgets not yet in context (which leads to runtime error)
  void clearResults({required bool doNotifyListeners}){
    _currentQuery = '';
    resultsList.clear();

    if(doNotifyListeners){
      notifyListeners();
    }
  }

  void selectResult(CsvRow row){
    selectedResult = row;
    canAdd = true;

    notifyListeners();
  }

  void deselectResult(CsvRow row){
    selectedResult = null;
    canAdd = false;

    notifyListeners();
  }
}
