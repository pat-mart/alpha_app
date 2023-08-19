

import '../plan_m.dart';

class WeatherData {
  // A more organized way of pulling API data that is part of the Plan model
  final WeatherTypes weatherType;
  Map<int, dynamic>? hourData;

  WeatherData({required this.weatherType});

  WeatherData.clearHours({required this.weatherType, required this.hourData});

  factory WeatherData.fromJson(Map<String, dynamic> json, Plan plan) {

    int startHour = plan.timespan.dateTimeRange.start.hour;
    int endHour = plan.timespan.dateTimeRange.end.hour;

    List<dynamic> allConditionsJoined = (json['forecast']['forecastday'] as List).expand((day) => day['hour'])
      .toList()
      .map((hour) => hour['condition']['text'].toString())
      .toList();
    //Consolidates every condition at every hour of all days involved in the span

    print(allConditionsJoined.sublist(startHour, endHour));

    final bool isClear = allConditionsJoined.sublist(startHour, endHour).every((condition) => condition == 'Clear');

    return WeatherData(weatherType: (isClear) ? WeatherTypes.good : WeatherTypes.bad);
  }
}

enum WeatherTypes {
  good,
  bad,
  unavailable
}
