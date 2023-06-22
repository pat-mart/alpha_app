import 'package:astro_planner/models/plan_m.dart';
import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/models/sky_object_m.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlanViewModel extends ChangeNotifier {

  final List<Plan> _planList = [];

  List<Plan> get planList => _planList;

  void addPlan(SkyObject skyObject, SetupModel setup) {
    _planList.add(Plan(skyObject, setup));
    notifyListeners();
  }

  void removeObject(int index) {
    _planList.removeAt(index);
    notifyListeners();
  }

  void editObject(int index, SkyObject skyObject, SetupModel setup){
    _planList[index] = Plan(skyObject, setup);
    notifyListeners();
  }

  void debugClearList(){
    _planList.clear();
    notifyListeners();
  }
}
