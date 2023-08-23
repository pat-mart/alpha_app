import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class CreatePlanViewModel extends ChangeNotifier {

  static final CreatePlanViewModel _instance = CreatePlanViewModel._();

  bool _serviceEnabled = false;
  bool _usingService = false;

  bool _usingFilter = false;

  ph.PermissionStatus? _permissionStatus;
  LocationData? _locData;

  final _permissionController = StreamController<ph.PermissionStatus>();

  double? _lat;
  double? _lon;

  double? _altFilter = -1;
  double? _azFilter = -1;

  Map<String, bool> validCoord = {'lat': false, 'lon': false}; //Lat, lon
  Map<String, bool> validFilter = {'alt': false, 'az': false};

  final Location _location = Location();

  DateTime? _startDateTime;

  DateTime? _endDateTime;

  CreatePlanViewModel._();

  factory CreatePlanViewModel(){
    return _instance;
  }

  @override
  void dispose(){
    _permissionController.close();

    super.dispose();
  }

  Future<void> get location async {

    await checkHasPermission();

    if(!_permissionStatus!.isGranted){
      _usingService = false;
      _serviceEnabled = false;
      _lat = _lon = null;

      return;
    }

    _serviceEnabled = true;

    _locData = await _location.getLocation().timeout(const Duration(seconds: 3));

    _lat = _locData?.latitude;
    _lon = _locData?.longitude;

    notifyListeners();
  }

  Future<void> checkHasPermission() async {
    _permissionStatus = await ph.Permission.locationWhenInUse.status;

    _serviceEnabled = _permissionStatus!.isGranted;

    if(!_serviceEnabled){
      _usingService = false;
    }

    notifyListeners();
  }

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await(Connectivity().checkConnectivity());

    return ([ConnectivityResult.ethernet, ConnectivityResult.wifi].contains(connectivityResult));
  }

  // Field validation and presentation logic

  void nullCoordinates(){
    _lat = _lon = null;
    notifyListeners();
  }

  void clearControllers(textEditingControllers){
    for(TextEditingController c in textEditingControllers){
      c.clear();
    }
    notifyListeners();
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
      validCoord['lat'] = true;
      return null;
    }
    return "Enter a valid latitude";
  }

  String? lonValidator(String? query) {
    if (_isInRange(query, -180, 180)) {
      validCoord['lon'] = true;
      return null;
    }
    return "Enter a valid longitude";
  }

  String? altValidator(String? query){
    if(_isInRange(query, 0, 90)){
      validFilter['alt'] = true;
      return null;
    }
    return "Enter a valid altitude";
  }

  String? azValidator(String? query){
    if(_isInRange(query, 0, 360)){
      validFilter['az'] = true;
      return null;
    }
    return "Enter a valid azimuth";
  }

  // Event handlers
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

  // Notifications

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

  // Getters

  bool get isUsingService => _usingService;

  bool get isUsingFilter => _usingFilter;

  bool get serviceEnabled => _serviceEnabled;

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

  // DateTime stuff

  DateTime? get getStartDateTime => _startDateTime;

  DateTime? get getEndDateTime => _endDateTime;

  set startDateTime(DateTime date){
    _startDateTime = date;
    notifyListeners();
  }

  set endDateTime(DateTime date){
    _endDateTime = date;
    notifyListeners();
  }
}

