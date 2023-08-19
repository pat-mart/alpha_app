import 'package:flutter/widgets.dart';
import 'package:location/location.dart';

import '../models/json_data/weather_data.dart';
import '../models/plan_m.dart';

class CreatePlanViewModel extends ChangeNotifier {

  static final CreatePlanViewModel _instance = CreatePlanViewModel._();

  bool _serviceEnabled = false;
  bool _usingService = false;

  bool _usingFilter = false;

  PermissionStatus? _permissionStatus;
  LocationData? _locData;

  double? _lat = 0;
  double? _lon = 0;

  double? _altFilter = -1;
  double? _azFilter = -1;

  List<bool> validCoord = [false, false]; //Lat, lon
  List<bool> validFilter = [false, false];

  final Location _location = Location();

  // Begin DateTime stuff
  DateTime? _startDate;
  DateTime? _startTime;

  Duration? _duration;

  bool? _startDateWithinRange;

  List<Plan>? _dataList = [];

  CreatePlanViewModel._();

  factory CreatePlanViewModel(){
    return _instance;
  }

  Future<void> getLocation() async {
    if(_permissionStatus == null) {
      _serviceEnabled = await _location.serviceEnabled();
      if (_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          _usingService = false;
          return;
        }
      }

      _permissionStatus = await _location.hasPermission();
      if (_permissionStatus == PermissionStatus.denied) {
        _permissionStatus = await _location.requestPermission();
        if (_permissionStatus != PermissionStatus.granted) {
          _usingService = false;
          return;
        }
      }

      try {
        _locData = await _location.getLocation();
      } catch (error) {
        _lat = double.nan;
        _lon = double.nan;
      }

      _lat = _locData!.latitude ?? double.nan;
      _lon = _locData!.longitude ?? double.nan;
    }
  }

  bool isNumeric(String query){
    if(query.isEmpty) {
      return false;
    }
    return double.tryParse(query).runtimeType == double;
  }

  String? numericValidator(String? query){
    if(!isNumeric(query!) && !isUsingService && query.isNotEmpty){
      return "Please enter a degree number.";
    }
    return null;
  }

  bool _isInRange(String? query, double minValue, double maxValue){
    if(query != null && query.isNotEmpty && numericValidator(query) == null) {
      if (double.parse(query) > minValue && double.parse(query) <= maxValue) {
        return true;
      }
      return false;
    }
    return (query != null) ? query.isEmpty : false;
  }

  String? latValidator(String? query){
    if(_isInRange(query, -90, 90)){
      validCoord[0] = true;
      return null;
    }
    return "Enter a valid latitude";
  }

  String? lonValidator(String? query) {
    return (_isInRange(query, -180, 180)) ? null : "Enter a valid longitude";
  }

  String? altValidator(String? query){
    return (_isInRange(query, 0, 90)) ? null : "Enter a valid altitude";
  }

  String? azValidator(String? query){
    return (_isInRange(query, 0, 360)) ? null : "Enter a valid azimuth";
  }

  double? _onChangeDegree(String newValue){
    double? x;
    if(isNumeric(newValue)){
      x = double.parse(double.parse(newValue).toStringAsFixed(3));
    }
    return x;
  }

  void onChangeLat(String newValue){
    _lat = _onChangeDegree(newValue);
  }

  void onChangeLon(String newValue){
    _lon = _onChangeDegree(newValue);
  }

  void onChangeAltFilter(String newValue){
    _altFilter = _onChangeDegree(newValue);
  }

  void onChangeAzFilter(String newValue){
    _azFilter = _onChangeDegree(newValue);
  }

  void clearFilters(){
    _lat = -1;
    _lon = -1;
    notifyListeners();
  }

  void showFilterWidgets(AnimationController controller) {
    if(_usingFilter){
      controller.forward();
    }
    else {
      controller.reverse();
    }
    notifyListeners();
  }

  bool get isUsingService => _usingService;

  bool get isUsingFilter => _usingFilter;

  LocationData? get locationData => _locData;

  double? get lat => _lat;

  double? get lon => _lon;

  set usingService (newVal) {
    _usingService = newVal;
    notifyListeners();
  }
  set serviceEnabled (newVal) {
    _serviceEnabled = newVal;
    notifyListeners();
  }
  set usingFilter (newVal){
    _usingFilter = newVal;
    notifyListeners();
  }
  //DateTime stuff starts here

  DateTime? get getStartDate => _startDate;

  Duration? get duration => _duration;

  List<WeatherData>? get iterableDays {
    if(_startDate == null){
      return null;
    }
    for(int i = 0; i < 3; i++){
      DateTime dateTime = _startDate!.add(Duration(days: i));
    }

  }

  set startDate(DateTime date){
    _startDate = date;
    notifyListeners();
  }

}

