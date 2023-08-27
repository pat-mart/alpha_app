import 'package:intl/intl.dart';

import '../plan_m.dart';

class WeatherData {

  static final DateFormat format = DateFormat('y-MM-ddTHH:MM:SSZ');

  WeatherData({required Map<int, List<DateTime?>> clearHoursByDay});

  /// Weather forecast times are in GMT
  factory WeatherData.fromJson(Map<String, dynamic> json, Plan plan) {

    List<dynamic> hours = json['forecastHourly']['hours'];

    List<DateTime> tempClearHours = [];

    Map<int, List<DateTime>> clearHoursByDay = {}; // Index of day, clear hours for that day

    for(int i = 0; i < hours.length; i++){
      if(hours[i]['conditionCode'] == 'Clear') {
        tempClearHours.add(DateTime.parse(hours[i]['forecastStart']).toLocal());
        if(i != hours.length && tempClearHours[i].day != tempClearHours[i+1].day){
          clearHoursByDay[0] = tempClearHours;
          tempClearHours.clear();
        }
      }
    }
    clearHoursByDay[1] = tempClearHours;
    tempClearHours.clear();

    return WeatherData(clearHoursByDay: clearHoursByDay);
  }
}
