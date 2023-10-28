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

  List<DateTime> clearHours = List.empty(growable: true);

  bool? isSuitable = false;
  bool hasData = false;

  WeatherData._({required this.weatherList, required this.hoursToDisplay, required this.forecastDays});

  WeatherData._days({required this.forecastDays});

  WeatherData._clearHours({required this.clearHours, required this.hasData, required this.isSuitable});

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

    if(timespan.startDateTime.toUtc().difference(DateTime.now().toUtc()).inHours > 24){
      return WeatherData._clearHours(clearHours: List.empty(), hasData: false, isSuitable: null);
    }

    int hourDiff = timespan.dateTimeRange.end.toUtc().hour - timespan.startDateTime.toUtc().hour;

    startIndex = timespan.startDateTime.toUtc().hour - DateTime.now().toUtc().hour;
    endIndex = (timespan.numDays > 2) ? 25 - startIndex : startIndex + hourDiff;

    List<dynamic> hours = json['forecastHourly']['hours'];

    List<DateTime> clearHours = List.empty(growable: true);

    bool suitable = true;

    for(int i = startIndex; i <= endIndex; i++){

      DateTime utcAsLocal = DateTime.parse('${hours[i]['forecastStart']}').toLocal();
      utcAsLocal = DateTime.utc(utcAsLocal.year, utcAsLocal.month, utcAsLocal.day, utcAsLocal.hour);

      if(hours[i]['conditionCode'] == 'Clear'){
        clearHours.add(utcAsLocal);
      }
      else {
        suitable = false;
      }
    }
    return WeatherData._clearHours(clearHours: clearHours, hasData: true, isSuitable: suitable);
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
