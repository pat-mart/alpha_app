import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../models/json_data/weather_data.dart';
import '../models/plan_m.dart';
import '../util/plan/date.dart';

class WeatherViewModel extends ChangeNotifier {

  DateTime _min = Date.current;
  DateTime _max = Date.max;

  DateTime _selectedDateTime = Date.forecastDays[0];
  int selectedIndex = 0;

  final DateFormat _dateFormat = DateFormat('EE, MMMM d');

  WeatherData? weatherData;

  static final WeatherViewModel instance = WeatherViewModel._();

  factory WeatherViewModel(){
    return instance;
  }

  WeatherViewModel._();

  String getFormattedDate() {
    return _dateFormat.format(_selectedDateTime);
  }

  void onChangeTime (int index) {
    _selectedDateTime = Date.forecastDays[index];
    selectedIndex = index;
    notifyListeners();
  }

  DateTime get selectedDateTime => _selectedDateTime;

  DateTime get minDateTime {
    _min = Date.forecastDays[0];
    return _min;
  }

  DateTime get maxDateTime {
    _max = DateTime.now().add(const Duration(days: 9));
    return _max;
  }

  void updateWeatherData() async {
    var createPlanVm = CreatePlanViewModel();

    if(createPlanVm.lat != null && createPlanVm.lon != null){
      weatherData = await Plan.onlyLocation(createPlanVm.lat!, createPlanVm.lon!).getWeatherData();
    }
    else {
      weatherData = null;
    }
    notifyListeners();
  }
}
