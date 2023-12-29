import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../create_plan_util.dart';

class LocationViewModel extends ChangeNotifier {
  double? lat, lon;

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
    _permissionStatus = await ph.Permission.locationWhenInUse.request();

    if (!_serviceEnabled) {
      _usingService = false;
      return false;
    }
    return true;
  }

  Future<void> get location async {
    await hasLocationPermission();

    if (!_permissionStatus!.isGranted) {
      _usingService = false;
      _serviceEnabled = false;
      lat = lon = null;

      notifyListeners();
      return;
    }

    _serviceEnabled = true;

    try {
      _locData =
          await _location.getLocation().timeout(const Duration(seconds: 5));
    } catch (e) {
      _locData = null;
      _usingService = false;
    }

    lat = _locData?.latitude;
    lon = _locData?.longitude;

    print('Called!');

    notifyListeners();
  }

  void clearControllers(List<TextEditingController> textEditingControllers) {
    for (final c in textEditingControllers) {
      c.clear();
    }
    notifyListeners();
  }

  void nullCoordinates() {
    lat = lon = null;
    notifyListeners();
  }

  void onChangeLat(String newValue, [bool notify = true]) {
    lat = CreatePlanUtil.onChangeDegree(newValue);
    if (notify) notifyListeners();
  }

  void onChangeLon(String newValue, [bool notify = true]) {
    lon = CreatePlanUtil.onChangeDegree(newValue);
    if (notify) notifyListeners();
  }

  String? latValidator(String? query) {
    if (CreatePlanUtil.isInRange(query, -90, 90)) {
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

  usingService(newVal, [bool notify = true]) {
    _usingService = newVal;
    if (notify) notifyListeners();
  }

  set serviceEnabled(newVal) {
    _serviceEnabled = newVal;
    notifyListeners();
  }

  bool get isUsingService => _usingService;

  bool get serviceEnabled => _serviceEnabled;

  bool get isValidLocation {
    return lon != null && lat != null;
  }

  LocationData? get locationData => _locData;
}
