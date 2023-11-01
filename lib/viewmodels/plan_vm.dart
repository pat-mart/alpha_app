import 'package:astro_planner/models/json_data/skyobj_data.dart';
import 'package:astro_planner/models/plan_m.dart';
import 'package:astro_planner/util/db/database_manager.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class PlanViewModel extends ChangeNotifier {

  final List<Plan> _planList = [];

  bool loadedPlans = false;

  bool didChangeFilter = false;

  static final PlanViewModel _instance = PlanViewModel._();

  factory PlanViewModel() => _instance;

  PlanViewModel._();

  Future<List<Plan>> get savedPlans async {
    final Database db = await DatabaseManager().database;

    await DatabaseManager().initDatabase();

    try {
      await db.query('plans', orderBy: 'id');
    }
    catch (e) {
      throw Exception(e);
    }

    final planList = await db.query('plans', orderBy: 'id');

    if(planList.isNotEmpty && !loadedPlans){
      for(final map in planList){
        final plan = Plan.fromMap(map);
        _planList.add(plan);
        if(plan.skyObjData != null){
          SearchViewModel().infoCache[plan.target.catalogName] = plan.skyObjData!;
        }
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
      throw Exception('You can store a maximum of 64 plans');
    }

    notifyListeners();
  }

  Future<void> updateSkyObjData(Plan toUpdate, SkyObjectData newData) async {
    final Database db = await DatabaseManager().database;

    toUpdate.skyObjData = newData;

    await db.update(
      'plans',
      toUpdate.toMap(),
      where: 'uuid = ?',
      whereArgs: [toUpdate.uuid]
    );
  }

  Future<void> update(Plan toUpdate, Plan newVersion) async {

    didChangeFilter = false;

    final Database db = await DatabaseManager().database;

    final uuid = toUpdate.uuid!;
    final index = _planList.indexOf(toUpdate);

    List<double> oldFilters = [toUpdate.altThresh, toUpdate.azMax, toUpdate.azMin];
    List<double> newFilters = [newVersion.altThresh, newVersion.azMax, newVersion.azMin];

    for(int i = 0; i < 3; i++){
      if(oldFilters[i] != newFilters[i]){
        didChangeFilter = true;
        break;
      }
    }

    toUpdate = newVersion;
    toUpdate.uuid = uuid; // Not sure if this is bad or not. Probably not

    _planList[index] = toUpdate;

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
