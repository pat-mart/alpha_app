import 'package:astro_planner/util/plan/csv_row.dart';
import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/json_data/skyobj_data.dart';
import '../models/plan_m.dart';

class SearchViewModel extends ChangeNotifier {

  static final SearchViewModel _instance = SearchViewModel._();


  List<CsvRow> resultsList = [];
  final List<CsvRow> _csvData = [];
  final List<SkyObjectData> _dataList = [];

  final Map<String, Plan?> _infoMap = {};

  final Map<String, CsvRow> _searchMap = {};
  final Map<String, CsvRow> _results = {};

  String _currentQuery = '';

  CreatePlanViewModel createPlanVm = CreatePlanViewModel();

  bool canUseData = false;

  SearchViewModel._();

  factory SearchViewModel(){
    return _instance;
  }

  Future<void> loadCsvData() async {
    if (_searchMap.isEmpty) {

      final astroData = await rootBundle.loadString('lib/assets/a_p_data.csv');

      List<List<dynamic>> data = const CsvToListConverter().convert(astroData);

      for (List<dynamic> row in data) {
        String key = (row[2] != 'Star')
            ? ',${row[0]},${row[1]},${row[5].toString().toUpperCase()}'
            : ',${row[1].toString().toUpperCase()} ${row[3].toUpperCase()},${row[0]},${row[5]}';
        CsvRow value = CsvRow(
            catalogName: row[0],
            catalogAlias: (row[1] is String) ? row[1] : '',
            objType: row[2],
            constellation: row[3],
            magnitude: (row[4] is num) ? row[4] : double.nan,
            properName: row[5]
        );
        _searchMap[key] = value;
      }
    }
  }

  String _cleanQuery(String query){
    return query.replaceAll(',', '');
  }

  Map<String, CsvRow> _filteredResults (String query) {

    final List<String> keysToRemove = [];
    final List<String> dataKeysToRemove = [];

    int count = _results.length;

    query = _cleanQuery(query).trim();

    if(query.isEmpty){
      return {};
    }

    _searchMap.forEach((key, value) {
      if(key.contains(',${query.toUpperCase()}') || key.contains(' ${query.toUpperCase()}')) {
        if(count <= 10){
          _results[key] = value;
          if(createPlanVm.lon != null && createPlanVm.lat != null && createPlanVm.getStartDate != null){
            _infoMap[key] =
              Plan.fromCsvRow(
                  value,
                  createPlanVm.getStartDate,
                  createPlanVm.duration,
                  createPlanVm.lat!,
                  createPlanVm.lon!
              );
          }
          count++;
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

    notifyListeners();
  }

  void loadTimeData() {

  }

  /// doNotifyListeners is used to prevent reloading of widgets not yet in context, even after Navigator.pop(context) is called.
  void clearResults({required bool doNotifyListeners}){
    _currentQuery = '';
    resultsList.clear();

    if(doNotifyListeners){
      notifyListeners();
    }
  }

  List<CsvRow> get csvData => _csvData;
}
