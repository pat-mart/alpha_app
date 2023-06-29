import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/models/target_m.dart';
import 'package:http/http.dart' as http;

import '../util/enums/weather_types.dart';
import '../util/plan/plan_timespan.dart';

class Plan {

  SkyObject _target;

  SetupModel _setup;

  PlanTimespan _timespan;

  late WeatherTypes _weather;

  final String apiKey = '6556c094f33b40a0976230554232406';

  Plan(this._target, this._setup, this._timespan);

  SkyObject get target => _target;

  SetupModel get setup => _setup;

  PlanTimespan get timespan => _timespan;

  void getWeather() async {
    final response = await http.get(Uri.parse('https://api.weatherapi.com/v1/astronomy.json?key=6556c094f33b40a0976230554232406&q=Jacksonville&dt=2023-06-25'));
  }

  Future<http.Response> _getData(double latitude, double longitude) async { //Time will be starting date as defined in Timespan
    final url = Uri.https('api.weatherapi.com', '/v1/astronomy.json?key=6556c094f33b40a0976230554232406&q=Sea Cliff&dt=2023-06-25');
    final response = await http.get(url);

    return response;
  }
}
