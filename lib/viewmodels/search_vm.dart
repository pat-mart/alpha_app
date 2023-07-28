import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SearchViewModel extends ChangeNotifier {

  static final SearchViewModel _instance = SearchViewModel._internal();

  final TextEditingController _searchController = TextEditingController();

  late List<List<dynamic>> _csvData = [];

  String _predictiveQuery = '';

  SearchViewModel._internal() {
    _searchController.addListener(() {
      updateQuery(_searchController.text);
    });
  }

  factory SearchViewModel(){
    return _instance;
  }

  Future<void> loadCsvData() async {
    final astroData = await rootBundle.loadString('a_p_data');

    List<List<dynamic>> data = const CsvToListConverter().convert(astroData);

    
  }

  void updateQuery(String query){
    _searchController.text = query;
    notifyListeners();
  }

  void clearInput () {
    controller.clear();
    notifyListeners();
  }

  void onChangeText() {
    //Eventually implement CSV matching here
  }

  String get _currentQuery => _searchController.text;

  TextEditingController get controller => _searchController;
}
