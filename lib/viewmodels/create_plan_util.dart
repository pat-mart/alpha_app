import 'package:astro_planner/models/json_data/weather_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/plan_m.dart';

abstract class CreatePlanUtil {

  static bool isNumeric(String query){
    if(query.isEmpty) {
      return false;
    }
    return double.tryParse(query).runtimeType == double;
  }

  static bool isInRange(String? query, double minValue, double maxValue){
    if(query != null && query.isNotEmpty && _numericValidator(query) == null) {
      return (double.parse(query) > minValue
          && double.parse(query) <= maxValue);
    }
    return (query != null) ? query.isEmpty : false;
  }

  static int? _numericValidator(String? query, [bool isUsingService = false]){
    if(!isNumeric(query!) && !isUsingService && query.isNotEmpty){
      return 0;
    }
    return null;
  }

  static double? onChangeDegree(String newValue){
    double? x;
    if(isNumeric(newValue)){
      x = double.parse(double.parse(newValue).toStringAsFixed(3));
    }
    return x;
  }

  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await(Connectivity().checkConnectivity());

    return ([ConnectivityResult.ethernet, ConnectivityResult.wifi, ConnectivityResult.mobile, ConnectivityResult.other, ConnectivityResult.vpn].contains(connectivityResult));
  }

  static Future<WeatherData>? getForecastDays(double? latitude, double? longitude) {
    if(latitude == null || longitude == null){
      return null;
    }

    return Plan.onlyLocation(latitude, longitude).forecastDays;
  }
}
extension Title on String {
  String toTitle(){
    return substring(0, 1).toUpperCase() + substring(1);
  }
}