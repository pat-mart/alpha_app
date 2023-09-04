import '../../util/plan/plan_timespan.dart';

class WeatherNode {

  DateTime time;

  String condition;

  bool isDay;

  WeatherNode({required this.time, required this.condition, required this.isDay});
}

class WeatherData {

  List<List<WeatherNode>> weatherList= [[]];
  List<List<int>> hoursToDisplay = List.empty(growable: true);
  List<DateTime> forecastDays = List.empty(growable: true);

  List<WeatherNode> clearHours = List.empty(growable: true);

  bool? isSuitable = false;

  WeatherData._({required this.weatherList, required this.hoursToDisplay, required this.forecastDays});

  WeatherData._forPlan({required this.isSuitable});

  WeatherData._days({required this.forecastDays});

  /// Weather forecast times are local to coordinates
  factory WeatherData.fromJson(Map<String, dynamic> weatherJson, Map<String, dynamic> timeJson) {

    List<dynamic> hours = weatherJson['forecastHourly']['hours'];

    List<List<int>> hoursToDisplay = List.empty(growable: true);
    List<int> tempHourList = List.empty(growable: true);

    List<List<WeatherNode>> weatherList = [[]];

    List<WeatherNode> tempList = List.empty(growable: true);

    List<DateTime> forecastDays = List.empty(growable: true);

    tempList.clear();
    tempHourList.clear();

    DateTime currentLocal = DateTime.parse('${timeJson['dateTime']}Z');
    currentLocal = DateTime.utc(currentLocal.year, currentLocal.month, currentLocal.day, currentLocal.hour);

    forecastDays.add(currentLocal);
    forecastDays.add(currentLocal.add(const Duration(hours: 24)));

    for(int i = 0; i <= 24; i++){
      tempHourList.add(currentLocal.add(Duration(hours: i)).hour);
    }

    hoursToDisplay.add(tempHourList.sublist(0, 24 - currentLocal.hour));
    hoursToDisplay.add(tempHourList.sublist(24 - currentLocal.hour));

    for(int i = 0; i < hours.length; i++) {
      tempList.add(WeatherNode(
        time: currentLocal.add(Duration(hours: i)),
        condition: hours[i]['conditionCode'],
        isDay: hours[i]['daylight'],
      ));
    }

    weatherList[0] = tempList.sublist(0, 24 - currentLocal.hour);
    weatherList.add(tempList.sublist(24 - currentLocal.hour));

    return WeatherData._(weatherList: weatherList, hoursToDisplay: hoursToDisplay, forecastDays: forecastDays);
  }

  factory WeatherData.planDuration(Map<String, dynamic> json, PlanTimespan timespan){
    int startIndex, endIndex;

    startIndex = timespan.startDateTime.toUtc().hour;
    endIndex = (timespan.numDays > 2) ? 25 - startIndex : timespan.dateTimeRange.end.toUtc().hour;
    if(timespan.numDays > 2){
      endIndex = 25 - startIndex;
    }
    else if(endIndex > 24){
      endIndex = 24;
    }

    List<dynamic> hours = json['forecastHourly']['hours'];

    for(int i = startIndex; i <= endIndex; i++){
      if(hours[i]['conditionCode'] != 'Clear'){
        return WeatherData._forPlan(isSuitable: false);
      }
    }
    return WeatherData._forPlan(isSuitable: true);
  }

  factory WeatherData.forecastDays(Map<String, dynamic> json){

    List<DateTime> forecastDays = List.empty(growable: true);

    DateTime currentLocal = DateTime.parse('${json['dateTime']}Z');
    currentLocal = DateTime.utc(currentLocal.year, currentLocal.month, currentLocal.day, currentLocal.hour);

    forecastDays.add(currentLocal);
    forecastDays.add(currentLocal.add(const Duration(hours: 24)));

    return WeatherData._days(forecastDays: forecastDays);
  }
}
