import 'package:flutter/widgets.dart';
import 'package:location/location.dart';

class CreatePlanViewModel extends ChangeNotifier {

  static final CreatePlanViewModel _instance = CreatePlanViewModel._();

  final TextEditingController _latController = TextEditingController(); // Mainly to clear both simultaneously
  final TextEditingController _lonController = TextEditingController();

  CreatePlanViewModel._();

  factory CreatePlanViewModel(){
    return _instance;
  }

  bool _serviceEnabled = false;
  bool _usingService = false;
  bool _isValidNum = true;

  bool _usingFilter = false;

  late PermissionStatus _permissionStatus;
  LocationData? _locData;

  num _lat = 0;
  num _lon = 0;

  double _latThreshold = -1;
  double _lonThreshold = -1;

  final Location _location = Location();

  Future<void> getLocation() async {
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

  bool isNumeric(String query){
    if(query.isEmpty) {
      return false;
    }
    Type type = num.tryParse(query).runtimeType;
    return type == double || type == int;
  }

  String? validator(String? query){
    if(!isNumeric(query!) && !isUsingService){
      return "Please enter a degree number.";
    }
    return null;
  }

  num _onChangeDegree(String newValue, num numericValue, TextEditingController controller){
    if(isNumeric(newValue)){
      numericValue = num.parse(num.parse(controller.text).toStringAsFixed(3));
    }
    return numericValue;
  }

  void onChangeLat(String newValue){
    _lat = _onChangeDegree(newValue, _lat, _latController);
  }

  void onChangeLon(String newValue){
    _lon = _onChangeDegree(newValue, _lon, _lonController);
  }

  void onChangeLatThreshold(String newValue){

  }

  void clearCoordFields() {
    _lonController.clear();
    _latController.clear();

    notifyListeners();
  }

  bool get isUsingService => _usingService;

  bool get isUsingFilter => _usingFilter;

  LocationData? get locationData => _locData;

  num get lat => _lat;

  num get lon => _lon;

  TextEditingController get latController => _latController;

  TextEditingController get lonController => _lonController;

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
}
