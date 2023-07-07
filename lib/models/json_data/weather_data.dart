
import '../plan_m.dart';

class WeatherData {
  // A more organized way of pulling API data that is part of the Plan model
  final WeatherTypes weatherType;

  WeatherData({required this.weatherType});

  factory WeatherData.fromJson(Map<String, dynamic> json, Plan plan) {

    int startHour = plan.timespan.dateRange.start.hour;

    List<dynamic> allConditionsJoined = (json['forecast']['forecastday'] as List).expand((day) => day['hour'])
      .toList()
      .map((hour) => hour['condition']['text'].toString())
      .toList();
    //Consolidates every condition at every hour of all days involved in the span

    final bool isClear = allConditionsJoined.sublist(startHour).every((condition) => condition == 'Clear');

    return WeatherData(weatherType: (isClear) ? WeatherTypes.good : WeatherTypes.bad);
  }
}

enum WeatherTypes {
  good,
  bad,
  unavailable
}
