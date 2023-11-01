import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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

    bool hasMax = (azMax != null && azMax != -1);
    bool hasMin = (azMin != null && azMin != -1);

    if(hasMin && !hasMax){
      if(!CreatePlanUtil.isInRange(query, 0, 360)) {
        validFilter['az_min'] = false;
        return "Enter a valid minimum azimuth";
      }
      validFilter['az_min'] = false;
      return "Enter a valid minimum azimuth";
    }
    else if(hasMin && hasMax){
      if(!CreatePlanUtil.isInRange(query, 0, (azMax! > azMin!) ? 360 : azMax!)) {
        validFilter['az_min'] = false;
        return "Enter a valid minimum azimuth";
      }
      validFilter['az_min'] = false;
      return "Enter a valid minimum azimuth";
    }
    else if(query != null && query.isNotEmpty){
      validFilter['az_min'] = false;
      return "Enter a valid minimum azimuth";
    }
    validFilter['az_min'] = true;
    return null;
  }

  String? azMaxValidator(String? query){

    bool hasMax = (azMax != null && azMax != -1);
    bool hasMin = (azMin != null && azMin != -1);

    print(azMin);
    print(azMax);

    if(hasMax && !hasMin && query != null && query.isNotEmpty){
      if(CreatePlanUtil.isInRange(query, 0, 360)){
        validFilter['az_max'] = true;
        return null;
      }
      validFilter['az_max'] = false;
      return "Enter a valid maximum azimuth";
    }
    else if(hasMax && hasMin && query != null && query.isNotEmpty){
        if(CreatePlanUtil.isInRange(query, azMin! > azMax! && azMin! > 0 ? 0 : azMin!, 360)){
          validFilter['az_max'] = true;
          return null;
        }
        validFilter['az_max'] = false;
        return "Enter a valid maximum azimuth";
    }
    else if(query != null && query.isNotEmpty){
      validFilter['az_max'] = false;
      return "Enter a valid maximum azimuth";
    }
    validFilter['az_max'] = true;
    return null;
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