import 'package:astro_planner/util/plan/csv_row.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SearchViewModel extends ChangeNotifier {

  static final SearchViewModel _instance = SearchViewModel._internal();

  final TextEditingController _searchController = TextEditingController();

  List<CsvRow> _csvData = [];
  late List<CsvRow> _results = [];

  SearchViewModel._internal();

  factory SearchViewModel(){
    return _instance;
  }

  Future<void> loadCsvData() async {
    final astroData = await rootBundle.loadString('lib/assets/a_p_data.csv');

    List<List<dynamic>> data = const CsvToListConverter().convert(astroData);

    _csvData = data.map(
      (row) {
        if(row[5] is!String) {
          return CsvRow(
              catalogName: row[0],
              catalogAlias: (row[2] != null) ? '' : row[2],
              objType: row[3],
              constellation: row[4],
              magnitude: row[5],
              properName: row[6]
          );
        }
        return CsvRow.empty();
      }
    ).toList();
  }

  List<List<dynamic>> sortedCsvData({sortIndex}) {
    if(csvData.isEmpty){
      throw Exception('CSV values not initialized');
    }
    return [];
  }

  void loadSearchResults(String q){

  }

  void clearInput () {
    controller.clear();
    notifyListeners();
  }

  TextEditingController get controller => _searchController;

  List<CsvRow> get csvData => _csvData;
}
