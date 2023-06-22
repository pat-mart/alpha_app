import 'package:flutter/material.dart';

import '../models/setup_m.dart';

class SetupViewModel extends ChangeNotifier {
  final List<SetupModel> _setupList = [];

  List<SetupModel> get setupList => _setupList;

  void addSetup(SetupModel newSetup){
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
