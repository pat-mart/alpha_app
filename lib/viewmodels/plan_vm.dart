import 'package:astro_planner/models/plan_m.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'list_vm.dart';

class PlanViewModel extends ChangeNotifier implements ListViewModel<Plan> {

  final List<Plan> _planList = [];

  static final PlanViewModel _instance = PlanViewModel._internal();

  factory PlanViewModel() {
    return _instance;
  }

  PlanViewModel._internal();

  @override
  List<Plan> get modelList => _planList;

  @override
  void addToList(Plan plan){
    _planList.add(plan);
    notifyListeners();
  }

  @override
  void removeModelAt(int index) {
    _planList.removeAt(index);
    notifyListeners();
  }

  @override
  void debugClearList(){
    _planList.clear();
    notifyListeners();
  }

  void removeModel(Plan plan){
    _planList.remove(plan);
  }

  void editPlan(int index, Plan newPlan){
    _planList[index] = newPlan;
    notifyListeners();
  }
}
