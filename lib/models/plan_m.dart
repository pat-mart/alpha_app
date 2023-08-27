import 'dart:io';

import 'package:astro_planner/models/json_data/skyobj_data.dart';
import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/models/sky_obj_m.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';

import '../util/plan/csv_row.dart';
import '../util/plan/plan_timespan.dart';
import '../viewmodels/create_plan_vm.dart';
import 'json_data/weather_data.dart';

class Plan {

  SkyObject? _target;

  Setup? _setup;

  PlanTimespan? _timespan;

  double _latitude, _longitude;

  double altThresh = -1;
  double azThresh = -1;

  dynamic httpClient = HttpClient();

  final Uuid uuidGen = const Uuid();
  late String uuid;

  final DateFormat _formatter = DateFormat('y-MM-ddTHH:MM:00');

  Plan(this._target, this._setup, this._timespan, this._latitude, this._longitude){
    uuid = uuidGen.v4();
  }

  Plan.fromCsvRow(CsvRow row, DateTime? startDate, DateTime? endDate, this._latitude, this._longitude){
    uuid = uuidGen.v4();
    _target = SkyObject.fromCsvRow(row);

    startDate = startDate ?? DateTime.now();
    endDate = startDate.add(const Duration(minutes: 1));

    _timespan = PlanTimespan(startDate, endDate.difference(startDate));
  }

  Plan.incomplete(this._latitude, this._longitude, DateTime? startDate){
    uuid = uuidGen.v4();
    if(startDate != null){
      _timespan = PlanTimespan(startDate, const Duration(hours: 72)); // Weather api can provide 3 day forecast
    }
  }

  Plan.onlyLocation(this._latitude, this._longitude);

  SkyObject get target => _target!;

  Setup get setup => _setup!;

  PlanTimespan get timespan => _timespan!;

  String get formattedStartDate => DateFormat('yyyy-MM-d').format(timespan.startDateTime);

  String get formattedEndDate => DateFormat('yyyy-MM-d').format(timespan.dateTimeRange.end);

  Future<WeatherData> getWeatherData() async {

    final String weatherKey = await rootBundle.loadString('assets/.weather_key', cache: false);

    Uri url = Uri.parse('https://weatherkit.apple.com/api/v1/weather/en-US/$_latitude/$_longitude?dataSets=forecastHourly&country=US');

    dynamic response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $weatherKey'
      }
    ).timeout(const Duration(seconds: 5));

    if(response.statusCode == 200){
      return WeatherData.fromJson(jsonDecode(response.body), this);
    }
    throw Exception('Error code ${response.statusCode}');
  }

  Future<SkyObjectData?> getObjInfo() async {
    Uri url = Uri.parse(
        'http://flask-env.eba-xndrjpjz.us-east-1.elasticbeanstalk.com'
            '/api/search?objname=${target.catName}&starttime=${_formatter.format(timespan.startDateTime)}'
            '&endtime=${_formatter.format(timespan.dateTimeRange.end)}&lat=$_latitude&lon=$_longitude&altthresh=$altThresh&azthresh=$azThresh'
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if(response.statusCode == 200) {
      var searchVm = SearchViewModel();

      //Caches data
      if(!searchVm.infoCache.containsKey(uuid)){
        searchVm.infoCache[uuid] = SkyObjectData.fromJson(jsonDecode(response.body));
      }
      else {
        return searchVm.infoCache[uuid];
      }
    }
    throw Exception('Error code ${response.statusCode}');
  }
}
