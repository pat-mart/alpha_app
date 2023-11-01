import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {

  DatabaseManager._();

  static final DatabaseManager instance = DatabaseManager._();
  static Database? db;

  factory DatabaseManager() => instance;

  Future<Database> get database async => db ??= await initDatabase();

  Future<void> clearDatabase() async {
    final db = await database;

    db.delete('plans');
  }

  Future<Database> initDatabase() async {
    Directory dbDirectory = await getApplicationDocumentsDirectory();
    String path = join(dbDirectory.path, 'plan_db.db');

    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1
    );
  }

  Future<int> get dbLength async {
    final db = await instance.database;

    return (await db.query('plans')).length;
  }

  Future<int> get intId async {
    final db = await instance.database;

    int maxOrder = Sqflite.firstIntValue(await db.rawQuery('SELECT MAX(num_id) FROM PLANS')) ?? 0;

    return maxOrder;
  }

  Future<void> execute(String sql) async {
    final db = await instance.database;
    await db.execute(sql);
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute(
      '''CREATE TABLE plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        sky_obj TEXT,
        sky_obj_data TEXT,
        latitude REAL,
        longitude REAL,
        az_filter_min REAL,
        az_filter_max REAL,
        alt_filter REAL,
        start_dt TEXT,
        end_dt TEXT,
        timezone TEXT,
        suitable_weather INTEGER
      )'''
    );
  }
}