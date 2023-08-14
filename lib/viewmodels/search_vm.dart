import 'package:astro_planner/util/plan/csv_row.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SearchViewModel extends ChangeNotifier {

  static final SearchViewModel _instance = SearchViewModel._();

  final TextEditingController _searchController = TextEditingController();

  final List<CsvRow> _csvData = [];
  List<CsvRow> resultsList = [];

  final Map<String, CsvRow> _searchMap = {};
  final Map<String, CsvRow> _results = {};

  SearchViewModel._();

  factory SearchViewModel(){
    return _instance;
  }

  Future<void> loadCsvData() async {
    final astroData = await rootBundle.loadString('lib/assets/a_p_data.csv');

    List<List<dynamic>> data = const CsvToListConverter().convert(astroData);

    if (_searchMap.isEmpty) {
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

    List<String> keysToRemove = [];

    int count = _results.length;

    query = _cleanQuery(query).trim();

    if(query.isEmpty){
      return {};
    }

    _searchMap.forEach((key, value) {
      if(key.contains(',${query.toUpperCase()}') || key.contains(' ${query.toUpperCase()}')) {
        if(count < 15){
          _results[key] = value;
          count++;
        }
      }
      else {
        if(_results.containsKey(key)){
          keysToRemove.add(key);
        }
      }
    });

    for(String key in keysToRemove){
      _results.remove(key);
    }

    return _results;
  }

  void loadSearchResults(String query) {
    resultsList = _filteredResults(query).values.toList();
    notifyListeners();
  }

  void clearInput () {
    controller.clear();
    resultsList.clear();

    notifyListeners();
  }

  TextEditingController get controller => _searchController;

  String get currentQuery => controller.text;

  List<CsvRow> get csvData => _csvData;
}
