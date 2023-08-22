import 'package:astro_planner/models/json_data/skyobj_data.dart';
import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/models/sky_obj_m.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';

import '../util/plan/csv_row.dart';
import '../util/plan/plan_timespan.dart';
import 'json_data/weather_data.dart';

class Plan {

  SkyObject? _target;

  Setup? _setup;

  PlanTimespan? _timespan;

  double _latitude, _longitude;

  double alt_thresh = -1;
  double az_thresh = -1;

  final String _weatherKey = '6556c094f33b40a0976230554232406';

  final Uuid uuidGen = const Uuid();
  late String uuid;

  final DateFormat _formatter = DateFormat('y-MM-dd HH:MM:SS');

  Plan(this._target, this._setup, this._timespan, this._latitude, this._longitude){
    uuid = uuidGen.v4();
  }

  Plan.fromCsvRow(CsvRow row, DateTime? startDate, DateTime? endDate, this._latitude, this._longitude){
    uuid = uuidGen.v4();
    _target = SkyObject.fromCsvRow(row);

    startDate ?? DateTime.now();
    endDate ?? DateTime.now().add(const Duration(minutes: 1));

    _timespan = PlanTimespan(startDate!, endDate!.difference(startDate!));
  }

  Plan.incomplete(this._latitude, this._longitude, DateTime? startDate){
    uuid = uuidGen.v4();
    if(startDate != null){
      _timespan = PlanTimespan(startDate, const Duration(hours: 72)); // Weather api can provide 3 day forecast
    }
  }

  SkyObject get target => _target!;

  Setup get setup => _setup!;

  PlanTimespan get timespan => _timespan!;

  String get formattedStartDate => DateFormat('yyyy-MM-d').format(timespan.startDateTime);

  String get formattedEndDate => DateFormat('yyyy-MM-d').format(timespan.dateTimeRange.end);

  Future<WeatherData> getFromWeatherApi({required RequestType requestType}) async {

    Uri url;

    if(requestType == RequestType.astro) {
      url = Uri.parse('https://api.weatherapi.com/v1/astronomy.json?key=$_weatherKey&q=$_latitude, $_longitude&dt=$formattedStartDate');
    }
    else {
      url = Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=$_weatherKey&q=$_latitude, $_longitude&days=${timespan.numDays}&aqi=no&alerts=no');
    }

    final response = await http.get(url);

    if(response.statusCode == 200){
      return WeatherData.fromJson(jsonDecode(response.body), this);
    }
    throw Exception('Error code ${response.statusCode}');
  }

  Future<SkyObjectData> getObjInfo() async {
    print(_formatter.format(timespan.dateTimeRange.end));
    Uri url = Uri.parse(
        'http://flask-env.eba-xndrjpjz.us-east-1.elasticbeanstalk.com'
            '/api/search?objname=${target.name}&starttime=${_formatter.format(timespan.startDateTime)}'
            '&endtime=${_formatter.format(timespan.dateTimeRange.end)}&lat=$_latitude&lon=-$_longitude&altthresh=$alt_thresh&azthresh=$az_thresh'
    );

    final response = await http.get(url);

    if(response.statusCode == 200) {
      return SkyObjectData.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error code ${response.statusCode}');
  }
}

enum RequestType{
  astro,
  forecast
}
