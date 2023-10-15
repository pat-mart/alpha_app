import 'package:astro_planner/models/plan_m.dart';
import 'package:astro_planner/util/db/database_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlanViewModel extends ChangeNotifier {

  final List<Plan> _planList = [];

  bool loadedPlans = false;

  static final PlanViewModel _instance = PlanViewModel._();

  factory PlanViewModel() => _instance;

  PlanViewModel._();

  Future<List<Plan>> get savedPlans async {
    final Database db = await DatabaseManager().database;
    final planList = await db.query('plans', orderBy: 'id');

    if(planList.isNotEmpty && !loadedPlans){
      for(final map in planList){
        _planList.add(Plan.fromMap(map));
      }
      loadedPlans = true;
    }
    return _planList;
  }

  Future<void> add(Plan toAdd) async {
    final Database db = await DatabaseManager().database;
    if((Sqflite.firstIntValue(await db.query('plans')) ?? 0) < 64){
      await db.insert(
        'plans',
        toAdd.toMap()
      );
      _planList.add(toAdd);
    }
    else {
      throw Exception('You can store a maximum of 64 plans.');
    }

    notifyListeners();
  }

  Future<void> update(Plan toUpdate) async {
    final Database db = await DatabaseManager().database;
    await db.update(
      'plans',
      toUpdate.toMap(),
      where: 'uuid = ?',
      whereArgs: [toUpdate.uuid]
    );
    notifyListeners();
  }

  Future<void> delete(String deleteUuid) async {
    final Database db = await DatabaseManager().database;

    if(await DatabaseManager().dbLength > 0 && _planList.isNotEmpty){
      await db.delete(
        'plans',
        where: 'uuid = ?',
        whereArgs: [deleteUuid]
      );
      _planList.removeWhere((plan) => plan.uuid == deleteUuid);
    }
    notifyListeners();
  }

  Plan getPlan(int index){
    return _planList.elementAt(index);
  }

  set planList (List<Plan> newList) => _planList;
}
