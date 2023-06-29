import 'package:flutter/material.dart';

class ListViewModel<Model> extends ChangeNotifier {

  List<Model> list = [];

  void addModel(Model model){
    list.add(model);
    notifyListeners();
  }

  void removeModel(int index){
    list.removeAt(index);
    notifyListeners();
  }

  void clearList(){
    list.clear();
    notifyListeners();
  }
}
