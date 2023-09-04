import 'package:astro_planner/viewmodels/create_plan/weather_vm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../create_plan_util.dart';

class LocationViewModel extends ChangeNotifier {

  double? _lat, _lon;

  bool _usingService = false;
  bool _serviceEnabled = true;

  bool hasInternet = false;

  Map<String, bool> validCoord = {'lat': false, 'lon': false};

  ph.PermissionStatus? _permissionStatus;

  LocationData? _locData;
  final Location _location = Location();

  static final instance = LocationViewModel._();

  LocationViewModel._();

  factory LocationViewModel() => instance;

  Future<bool> hasLocationPermission() async {
    _permissionStatus = await ph.Permission.locationWhenInUse.status;

    _serviceEnabled = _permissionStatus!.isGranted;

    if (!_serviceEnabled) {
      _usingService = false;
      return false;
    }
    return true;
  }

  Future<void> get location async {

    await hasLocationPermission();

    if(!_permissionStatus!.isGranted){
      _usingService = false;
      _serviceEnabled = false;
      _lat = _lon = null;

      notifyListeners();
      return;
    }

    _serviceEnabled = true;

    _locData = await _location.getLocation().timeout(const Duration(seconds: 4));

    _lat = _locData?.latitude;
    _lon = _locData?.longitude;

    notifyListeners();
  }

  void clearControllers(List<TextEditingController> textEditingControllers){
    for(final c in textEditingControllers){
      c.clear();
    }
    notifyListeners();
  }

  void nullCoordinates(){
    _lat = _lon = null;
    notifyListeners();
  }

  void onChangeLat(String newValue){
    _lat = CreatePlanUtil.onChangeDegree(newValue);
    if(_lat != null && hasInternet) {
      WeatherViewModel().dataCache.clear();
    }
    notifyListeners();
  }

  void onChangeLon(String newValue){
    _lon = CreatePlanUtil.onChangeDegree(newValue);
    if(_lon != null && hasInternet){
      WeatherViewModel().dataCache.clear();
    }

    notifyListeners();
  }

  String? latValidator(String? query){
    if(CreatePlanUtil.isInRange(query, -90, 90)){
      validCoord['lat'] = true;
      return null;
    }
    validCoord['lat'] = false;
    return "Enter a valid latitude";
  }

  String? lonValidator(String? query) {
    if (CreatePlanUtil.isInRange(query, -180, 180)) {
      validCoord['lon'] = true;
      return null;
    }
    validCoord['lon'] = false;
    return "Enter a valid longitude";
  }

  set usingService(newVal){
    _usingService = newVal;
    notifyListeners();
  }
  set serviceEnabled(newVal){
    print(newVal);
    _serviceEnabled = newVal;
    notifyListeners();
  }

  double? get lat => _lat;

  double? get lon => _lon;

  bool get isUsingService => _usingService;

  bool get serviceEnabled => _serviceEnabled;

  bool get isValidLocation {
    return _lon != null && _lat != null;
  }

  LocationData? get locationData => _locData;
}