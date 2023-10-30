import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/json_data/weather_data.dart';

class WeatherViewModel extends ChangeNotifier {

  int selectedIndex = 0;

  WeatherData? weatherData;

  final Map<int, Future<WeatherData?>?> _weatherCache = {};

  List<DateTime>? dayCache;

  bool _usingCelsius = false;

  static final WeatherViewModel instance = WeatherViewModel._();

  factory WeatherViewModel() => instance;

  WeatherViewModel._();

  Map<int, Future<WeatherData?>?> get dataCache => _weatherCache;

  bool get usingCelsius => _usingCelsius;

  Future<bool> get usingCelsiusAsync async {
    final sharedPrefs = await SharedPreferences.getInstance();

    if(sharedPrefs.getBool('usingCelsius') ?? false){
      _usingCelsius = sharedPrefs.getBool('usingCelsius')!;
    }
    return _usingCelsius;
  }

  Future<void> setUsingCelsius(newVal) async {
    _usingCelsius = newVal;

    final sharedPrefs = await SharedPreferences.getInstance();

    sharedPrefs.setBool('usingCelsius', _usingCelsius);

    notifyListeners();
  }

  void startTimer(Duration minToHour) {
    Timer(minToHour, () {
      notifyListeners();
      Timer.periodic(const Duration(hours: 1), (timer) {
        notifyListeners();
      });
    });
  }

  void startAutoRefresh(Duration min){

  }

  void onChangeTime (int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void cacheData(Future<WeatherData?>? data, int? index){
    if(data == null || index == null){
      return;
    }
    _weatherCache[index] = data;
  }

  void clearCaches([bool notify = true]){
    _weatherCache.clear();
    if(notify) notifyListeners();
  }

  void removeFromCache(int index){
    _weatherCache.remove(index);
    notifyListeners();
  }
}
