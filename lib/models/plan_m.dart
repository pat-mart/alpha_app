import 'dart:io';

import 'package:astro_planner/models/json_data/skyobj_data.dart';
import 'package:astro_planner/models/sky_obj_m.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';

import '../util/plan/csv_row.dart';
import '../util/plan/plan_timespan.dart';
import 'json_data/weather_data.dart';

class Plan {

  SkyObject? _target;

  SkyObjectData? _apiData;

  PlanTimespan? _timespan;

  double _latitude, _longitude;

  double altThresh = -1;
  double azMin = -1;
  double azMax = -1;

  String timezone = '';

  bool weatherSuitable = false;

  final httpClient = HttpClient();

  final Uuid uuidGen = const Uuid();
  late String uuid;
  int? primaryKey;

  final DateFormat _formatter = DateFormat('y-MM-ddTHH:MM:00');

  Plan(this._target, this._timespan, this._latitude, this._longitude, this.timezone, this._apiData, [this.primaryKey]){
    uuid = uuidGen.v4();
  }

  Plan.fromCsvRow(CsvRow row, DateTime? startDate, DateTime? endDate, this._latitude, this._longitude){
    uuid = uuidGen.v4();
    _target = SkyObject.fromCsvRow(row);

    startDate = startDate ?? DateTime.now();
    endDate = startDate.add(const Duration(minutes: 1));

    _timespan = PlanTimespan(startDate, endDate);
  }

  Plan.incomplete(this._latitude, this._longitude, this.azMin, this.altThresh, DateTime? startDate){
    uuid = uuidGen.v4();
    if(startDate != null){
      _timespan = PlanTimespan(startDate, startDate.add(const Duration(hours: 48)));
    }
  }

  Plan.onlyLocation(this._latitude, this._longitude);

  factory Plan.fromMap(Map<String, dynamic> map){
    PlanTimespan timespan = PlanTimespan(DateTime.parse(map['startTime']), DateTime.parse(map['endTime']));
    return Plan(
      SkyObject.fromString(map['sky_obj']),
      timespan,
      map['latitude'],
      map['longitude'],
      map['timezone'],
      SkyObjectData.fromString(map['sky_obj_data'])
    );
  }

  SkyObject get target => _target!;

  PlanTimespan get timespan => _timespan!;

  String get formattedStartDate => DateFormat('yyyy-MM-d').format(timespan.startDateTime);

  String get formattedEndDate => DateFormat('yyyy-MM-d').format(timespan.dateTimeRange.end);

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'start_dt': _timespan!.startDateTime.toIso8601String(),
      'end_dt': _timespan!.dateTimeRange.end.toIso8601String(),
      'latitude': _latitude,
      'longitude': _longitude,
      'sky_obj': _target.toString(),
      'sky_obj_data': _apiData.toString(),
      'az_filter_min': azMin,
      'az_filter_max': azMax,
      'alt_filter': altThresh,
      'suitable_weather': weatherSuitable,
      'timezone': timezone
    };
  }

  Future<WeatherData?> getWeatherData([RequestType requestType = RequestType.forecast]) async {

    final String weatherKey = await rootBundle.loadString('assets/.weather_key', cache: false);

    Uri weatherUrl = Uri.parse('https://weatherkit.apple.com/api/v1/weather/en-US/$_latitude/$_longitude?dataSets=forecastHourly&country=US');
    Uri timeUrl = Uri.parse('https://timeapi.io/api/Time/current/coordinate?latitude=$_latitude&longitude=$_longitude');

    dynamic weatherResponse = await http.get(
      weatherUrl,
      headers: {
        'Authorization': 'Bearer $weatherKey'
      }
    ).timeout(const Duration(seconds: 5)).onError((error, stackTrace) => throw Exception(error));

    dynamic timeResponse = await http.get(timeUrl).timeout(const Duration(seconds: 5));

    if(weatherResponse.statusCode == 200 && timeResponse.statusCode == 200){
      if(requestType == RequestType.planDuration){
        if(_timespan != null && _timespan!.startDateTime.difference(DateTime.now()).inHours <= 24){
          return WeatherData.planDuration(jsonDecode(weatherResponse.body), timespan);
        }
        else {
          return null;
        }
      }
      return WeatherData.fromJson(jsonDecode(weatherResponse.body), jsonDecode(timeResponse.body));
    }
    throw Exception('Weather error code ${weatherResponse.statusCode}');
  }

  Future<WeatherData> get forecastDays async {
    Uri timeUrl = Uri.parse('https://timeapi.io/api/Time/current/coordinate?latitude=$_latitude&longitude=$_longitude');

    dynamic timeResponse = await http.get(timeUrl)
        .timeout(const Duration(seconds: 5))
        .onError((error, stackTrace) => throw Exception(error));

    if(timeResponse.statusCode == 200){
      return WeatherData.forecastDays(jsonDecode(timeResponse.body));
    }
    throw Exception('Weather error code ${timeResponse.statusCode}');
  }

  Future<SkyObjectData?> getObjInfo() async {

    Uri url = Uri.parse(
      'http://flask-env.eba-xndrjpjz.us-east-1.elasticbeanstalk.com'
          '/api/search?objname=${target.catName}&starttime=${_formatter.format(timespan.startDateTime)}'
          '&endtime=${_formatter.format(timespan.dateTimeRange.end)}&lat=$_latitude&lon=$_longitude&altthresh=$altThresh&azthresh=$azMin'
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if(response.statusCode == 200) {

      final searchVm = SearchViewModel();
      //Caches data
      if(!searchVm.infoCache.containsKey(uuid)){
        searchVm.infoCache[uuid] = _apiData = SkyObjectData.fromJson(jsonDecode(response.body));
      }
      else {
        return searchVm.infoCache[uuid];
      }
    }
    throw Exception('Error code ${response.statusCode}');
  }
}

enum RequestType {
  forecast,
  planDuration
}
