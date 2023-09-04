import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {


  DatabaseManager._();

  static final DatabaseManager instance = DatabaseManager._();
  static Database? db;

  Future<Database> get database async => db ??= await _initDatabase();

  // Future<Database> get database => database ??= await initDatabase()
  Future<Database> _initDatabase() async {
    Directory dbDirectory = await getApplicationDocumentsDirectory();
    String path = join(dbDirectory.path, 'plans.db');

    return await openDatabase(
      path,
      onCreate: _onCreate;
    );
  }

  Future<int> get intId async {
    final db = await instance.database;

    int maxOrder = Sqflite.firstIntValue(await db.rawQuery('SELECT MAX(num_id) FROM PLANS')) ?? 0;

    return maxOrder;
  }

  Future<void> _onCreate() async {
    final db = await instance.database;
    await db.execute(

      '''
      CREATE TABLE plans(
        num_id INTEGER PRIMARY KEY
        uuid TEXT
        sky_obj TEXT
        sky_obj_data TEXT
        az_filter_min REAL
        az_filter_max REAL
        alt_filter REAL
        start_dt TEXT
        end_dt TEXT
      )
      '''
    );
  }
}