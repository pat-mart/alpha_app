import 'package:astro_planner/models/plan_m.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlanViewModel extends ChangeNotifier {

  final List<Plan> _planList = [];

  List<Plan> get planList => _planList;

  static final PlanViewModel _instance = PlanViewModel._internal();

  factory PlanViewModel() {
    return _instance;
  }

  PlanViewModel._internal();

  void addPlan(Plan plan){
    _planList.add(plan);
    notifyListeners();
  }

  void removeObject(int index) {
    _planList.removeAt(index);
    notifyListeners();
  }

  void editObject(int index, Plan newPlan){
    _planList[index] = newPlan;
    notifyListeners();
  }

  void debugClearList(){
    _planList.clear();
    notifyListeners();
  }
}
