import 'dart:io';

import 'package:astro_planner/models/json_data/skyobj_data.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:alpha_lib/alpha_lib.dart';
import 'dart:convert';

import '../util/plan/date.dart';
import '../viewmodels/plan_vm.dart';
import 'sky_obj_m.dart';
import '../util/plan/plan_timespan.dart';
import 'json_data/weather_data.dart';

class Plan {

  SkyObj? _target;

  SkyObjectData? skyObjData;

  PlanTimespan? _timespan;

  double latitude, longitude;

  double altThresh = -1;

  double azMin = -1;
  double azMax = -1;

  String timezone = '';

  bool weatherSuitable = false;

  final httpClient = HttpClient();

  final Uuid uuidGen = const Uuid();
  String? uuid;
  int? primaryKey;

  final DateFormat _timeFormatter = DateFormat('y-M-d HH:mm');

  Plan(this._target, DateTime startDt, DateTime endDt, this.latitude, this.longitude, this.timezone, this.skyObjData, [this.weatherSuitable=false, this.azMax=-1, this.azMin=-1, this.altThresh=-1, this.uuid]){
    uuid ??= uuidGen.v4();
    _timespan = PlanTimespan(startDt, endDt);
  }

  Plan.fromCsvRow(this._target, DateTime? startDate, DateTime? endDate, this.latitude, this.longitude){
    uuid = uuidGen.v4();

    startDate = startDate ?? DateTime.now();
    endDate = startDate.add(const Duration(minutes: 1));

    _timespan = PlanTimespan(startDate, endDate);
  }

  Plan.incomplete(this.latitude, this.longitude, this.azMin, this.altThresh, DateTime? startDate){
    uuid = uuidGen.v4();
    if(startDate != null){
      _timespan = PlanTimespan(startDate, startDate.add(const Duration(hours: 48)));
    }
  }

  Plan.onlyLocation(this.latitude, this.longitude);

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      SkyObj.fromString(map['sky_obj']),
      DateTime.parse(map['start_dt']),
      DateTime.parse(map['end_dt']),
      map['latitude'],
      map['longitude'],
      map['timezone'],
      map['sky_obj_data'] == 'null' ? null : SkyObjectData.fromString(map['sky_obj_data']),
      (map['suitable_weather'] == 1),
      map['az_filter_max'],
      map['az_filter_min'],
      map['alt_filter'],
      map['uuid']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_dt': _timespan!.startDateTime.toIso8601String(),
      'end_dt': _timespan!.dateTimeRange.end.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'sky_obj': _target.toString(),
      'sky_obj_data': skyObjData.toString(),
      'az_filter_min': azMin,
      'az_filter_max': azMax,
      'alt_filter': altThresh,
      'suitable_weather': (weatherSuitable) ? 1 : 0,
      'timezone': timezone,
      'uuid': uuid
    };
  }

  SkyObj get target => _target!;

  PlanTimespan get timespan => _timespan!;

  String get formattedStartDate => DateFormat('yyyy/MM/d').format(timespan.startDateTime);

  String get formattedEndDate => DateFormat('yyyy/MM/d').format(timespan.dateTimeRange.end);

  Future<WeatherData?> getWeatherData([RequestType requestType = RequestType.forecast]) async {

    final String weatherKey = await rootBundle.loadString('assets/.weather_key', cache: false);

    Uri weatherUrl = Uri.parse('https://weatherkit.apple.com/api/v1/weather/en-US/$latitude/$longitude?dataSets=forecastHourly&country=US');
    Uri timeUrl = Uri.parse('https://timeapi.io/api/Time/current/coordinate?latitude=$latitude&longitude=$longitude');

    dynamic weatherResponse = await http.get(
      weatherUrl,
      headers: {
        'Authorization': 'Bearer $weatherKey'
      }
    ).timeout(const Duration(seconds: 10)).onError((error, stackTrace) => throw Exception(error));

    dynamic timeResponse = await http.get(timeUrl).timeout(const Duration(seconds: 10));

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
    Uri timeUrl = Uri.parse('https://timeapi.io/api/Time/current/coordinate?latitude=$latitude&longitude=$longitude');

    dynamic timeResponse = await http.get(timeUrl)
        .timeout(const Duration(seconds: 5))
        .onError((error, stackTrace) => throw Exception(error));

    if(timeResponse.statusCode == 200){
      return WeatherData.forecastDays(jsonDecode(timeResponse.body));
    }
    throw Exception('Weather error code ${timeResponse.statusCode}');
  }

  Future<SkyObjectData?> getDeepSkyInfo([bool isPlan = false, double utcOffset = 0]) async {
    if(target.ra.isNaN || target.dec.isNaN || _timespan == null){
      return null;
    }

    var filters = [altThresh, azMin, azMax];
    for (int i = 0; i < 3; i++){
      if(filters[i] != -1){
        filters[i] = filters[i].toRadians(Units.degrees);
      }
    }

    DeepSky obj = DeepSky(latitude: latitude, longitude: longitude, raRad: target.ra, decRad: target.dec, time: _timespan!.startDateTime.toUtc(), utcOffset: 0, maxAz: azMax, minAz: azMin, minAlt: altThresh);

    dynamic hoursVis = Date.hoursToDtList(_timespan!.startDateTime.toUtc(), obj.hoursVisible.normalizedRadianTimes, utcOffset);

    hoursVis ??= [-1, -1];

    dynamic hoursSuggested = Date.hoursToDtList(_timespan!.startDateTime.toUtc(), obj.hoursSuggested.normalizedRadianTimes, utcOffset);

    hoursSuggested ??= [-1, -1];

    dynamic peakTime = Date.hourToDt(_timespan!.startDateTime.toUtc(), obj.peakInfo['time']!);

    peakTime ??= '';

    if(peakTime != null && peakTime != -1){
      peakTime = _timeFormatter.format(peakTime);
    }


    final data = SkyObjectData(
        hoursVis: [hoursVis[0].toString(), hoursVis[1].toString()], hoursSuggested: [hoursSuggested[0].toString(), hoursSuggested[1].toString()],
        peakTime: peakTime.toString(), name: target.catalogName, peakBearing: obj.peakInfo['az']!.toDegrees(Units.radians), peakAlt: obj.peakInfo['alt']!.toDegrees(Units.radians),
        dateEntered: timespan.startDateTime, neverRises: obj.localRiseSetTimes[0] == -1.0, neverSets: obj.localRiseSetTimes[0] == 0.0);

    return data;
  }

  Future<SkyObjectData?> getPlanetInfo(int listLength, httpsClient, DateTime dateSaved, [bool isPlan = false]) async {

    if(SearchViewModel().infoCache.containsKey(target.catalogName) && !PlanViewModel().didChangeFilter){
      skyObjData = SearchViewModel().infoCache[target.catalogName];

      return SearchViewModel().infoCache[target.catalogName];
    }

    Uri url = Uri.parse(
      'https://api.astro-alpha.com/api/search?objname=${target.catalogName}&starttime=${_timeFormatter.format(timespan.startDateTime)}'
          '&endtime=${_timeFormatter.format(timespan.dateTimeRange.end)}&lat=$latitude&lon=$longitude&altthresh=$altThresh&azmin=$azMin&azmax=$azMax'
    );

    HttpClientRequest request = await httpsClient.getUrl(url);

    SearchViewModel().objQueryMap[target] = request;

    HttpClientResponse response = await request.close().timeout(const Duration(seconds: 30));

    if(response.statusCode == 200) {
      final searchVm = SearchViewModel();

      final stringData = await response.transform(utf8.decoder).join();

      searchVm.infoCache[target.catalogName] = SkyObjectData.fromJson(jsonDecode(stringData), timespan.startDateTime);
      skyObjData = searchVm.infoCache[target.catalogName];

      if(isPlan){
        await PlanViewModel().updateSkyObjData(this, skyObjData!);
      }
      return skyObjData;
    }
    return null;
  }
}

enum RequestType {
  forecast,
  planDuration
}
