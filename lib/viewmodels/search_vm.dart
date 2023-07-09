import 'package:flutter/cupertino.dart';

import '../models/sky_obj_m.dart';
import 'list_vm.dart';

class SearchViewModel extends ChangeNotifier implements ListViewModel<SkyObject> {

  final List<SkyObject> _list = [];

  static final SearchViewModel _instance = SearchViewModel._internal();

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';

  SearchViewModel._internal(){
    _searchController.addListener(() {
      updateQuery(_searchController.text);
    });
  }

  factory SearchViewModel(){
    return _instance;
  }

  void updateQuery(String query){
    searchQuery = query;
    notifyListeners();
  }

  TextEditingController get controller => _searchController;

  void clearInput () => controller.clear();

  @override
  List<SkyObject> get modelList => _list;

  @override
  void addToList(SkyObject target) {
    _list.add(target);
  }

  @override
  void removeModelAt(int index) {
    _list.removeAt(index);
  }

  @override
  void debugClearList() {
    _list.clear();
  }
}
