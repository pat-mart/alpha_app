import 'package:flutter/material.dart';

class ListViewModel<Model> extends ChangeNotifier {

  List<Model> list = [];

  void addSetup(Model model){
    list.add(model);
    notifyListeners();
  }

  void removeSetup(int index){
    list.removeAt(index);
    notifyListeners();
  }

  void clearList(){
    list.clear();
    notifyListeners();
  }
}
