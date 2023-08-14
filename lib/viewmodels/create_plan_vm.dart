import 'package:flutter/widgets.dart';
import 'package:location/location.dart';

class CreatePlanViewModel extends ChangeNotifier {

  static final CreatePlanViewModel _instance = CreatePlanViewModel._();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  CreatePlanViewModel._();

  factory CreatePlanViewModel(){
    return _instance;
  }

  bool _serviceEnabled = false;
  bool _usingService = true;
  bool _isValidNum = true;

  late PermissionStatus _permissionStatus;
  late LocationData? _locData;

  num _lat = 0;
  num _lon = 0;

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

  bool isValidNumber(String query){
    if(query.isEmpty) {
      return false;
    }
    Type type = num.tryParse(query).runtimeType;
    return type == double || type == int;
  }

  String? validator(String? query){
    if(!isValidNumber(query!) && !isUsingService){
      return "Please enter a number.";
    }
    return null;
  }

  String? _onChange(String newValue, TextEditingController controller) {
    if(isValidNumber(newValue)) {
      return controller.text;
    }
    return null;
  }

  void onChangeLat(String newValue){
    if(isValidNumber(newValue)) {
      _lat = num.parse(_onChange(newValue, _latController)!);
    }
  }

  void onChangeLon(String newValue){
    if(isValidNumber(newValue)) {
      _lon = num.parse(num.parse(_lonController.text).toStringAsFixed(3));
    }
  }

  void clearFields() {
    _lonController.clear();
    _latController.clear();

    notifyListeners();
  }

  void onChanged(String newValue) {
    _isValidNum = isValidNumber(newValue);

    if(_isValidNum){
      _lat = num.parse(num.parse(_latController.text).toStringAsFixed(3));
    }
  }

  bool get isUsingService => _usingService;

  bool get serviceEnabled => _serviceEnabled;

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
}
