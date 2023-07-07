import 'package:flutter/material.dart';

import '../models/setup_m.dart';

class SetupViewModel extends ChangeNotifier {

  final List<Setup> _setupList = [];

  List<Setup> get setupList => _setupList;

  static final SetupViewModel _instance = SetupViewModel._internal();

  factory SetupViewModel() {
    return _instance;
  }

  SetupViewModel._internal();

  void addSetup(Setup newSetup){
    _setupList.add(newSetup);
    notifyListeners();
  }

  void removeSetup(int index){
    _setupList.removeAt(index);
    notifyListeners();
  }

  void debugClearList(){
    _setupList.clear();
    notifyListeners();
  }
}
