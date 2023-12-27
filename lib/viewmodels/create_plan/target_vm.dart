import 'package:flutter/cupertino.dart';

import '../create_plan_util.dart';

class TargetViewModel extends ChangeNotifier {

  bool _isUsingFilter = false;
  bool hasTarget = false;

  double? altFilter = -1;

  double? azMin = -1;
  double? azMax = -1;

  Map<String, bool> validFilter = {'alt': true, 'az_min': true, 'az_max': true};

  static final instance = TargetViewModel._();

  TargetViewModel._();

  factory TargetViewModel() => instance;

  String? altValidator(String? query){
    if(CreatePlanUtil.isInRange(query, 0, 90)){
      validFilter['alt'] = true;
      return null;
    }
    validFilter['alt'] = false;
    return "Enter a valid altitude";
  }

  String? azMinValidator(String? query){

    bool hasRangedMax = (azMax != null && azMax! > 0 && azMax!  < 360);
    bool hasRangedMin = (azMin != null && azMin! > 0 && azMin! < 360);

    if(azMin == null && (query ?? '').isEmpty){
      validFilter['az_min'] = true;
      return null;
    }

    else if(hasRangedMin){
      if(!hasRangedMax || (azMin! < azMax!)){
        validFilter['az_min'] = true;
        return null;
      }
    }
    validFilter['az_min'] = false;
    return "Enter a valid minimum azimuth";
  }

  String? azMaxValidator(String? query){

    bool hasRangedMax = (azMax != null && azMax! > 0 && azMax!  < 360);
    bool hasRangedMin = (azMin != null && azMin! > 0 && azMin!  < 360);

    if(azMax == null){
      validFilter['az_max'] = true;
      return null;
    }

    else if(hasRangedMax){
      if(!hasRangedMin || (azMax! > azMin!)){
        validFilter['az_max'] = true;
        return null;
      }
    }

    validFilter['az_max'] = false;
    return "Enter a valid maximum azimuth";
  }

  bool get isValidFilter {
    return validFilter.values.every((element) => element);
  }

  void onChangeAltFilter(String newValue, [bool notify=true]){
    altFilter = CreatePlanUtil.onChangeDegree(newValue);
    if(notify) notifyListeners();

  }

  void onChangeAzMin(String newValue, [bool notify=true]){
    azMin = CreatePlanUtil.onChangeDegree(newValue);
    if(notify) notifyListeners();
  }

  void onChangeAzMax(String newValue, [bool notify=true]){
    azMax = CreatePlanUtil.onChangeDegree(newValue);
    if(notify) notifyListeners();
  }

  void clearFilters(){
    altFilter = null;
    azMin = null;
    azMax = null;

    validFilter['alt'] = true;
    validFilter['az_min'] = true;
    validFilter['az_max'] = true;

    notifyListeners();
  }

  void showFilterWidgets(AnimationController controller){
    if(_isUsingFilter){
      controller.forward();
    }
    else {
      controller.reverse();
    }
    notifyListeners();
  }

  void usingFilter(newVal, [bool notify=true]){
    _isUsingFilter = newVal;
    if(notify) notifyListeners();
  }

  bool get isUsingFilter => _isUsingFilter;
}