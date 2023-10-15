import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../create_plan_util.dart';

class TargetViewModel extends ChangeNotifier {

  bool _isUsingFilter = false;

  double? altFilter = -1;

  double? azMin = -1;
  double? azMax = -1;

  Map<String, bool> validFilter = {'alt': false, 'az': false};

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

  String? _azValidator(String? query, bool condition){
    if(query == null){
      validFilter['az'] = true;
      return null;
    }
    else if(CreatePlanUtil.isInRange(query, 0, 360)){
      if(condition){
        validFilter['az'] = true;
        return null;
      }
    }
    validFilter['az'] = false;
    return "Enter a valid azimuth";
  }

  String? azMinValidator(String? query){

    bool hasMax = azMax != null;
    bool hasMin = azMin != null;

    if(hasMin && !hasMax){
      return CreatePlanUtil.isInRange(query, 0, 360) ? null : "Enter a valid minimum azimuth";
    }
    else if(hasMin && hasMax){
      return (CreatePlanUtil.isInRange(query, 0, azMax! < azMin! ? 360 : azMax!)) ? null : "Enter a valid minimum azimuth";
    }
    return null;
  }

  String? azMaxValidator(String? query){

    bool hasMax = azMax != null;
    bool hasMin = azMin != null;

    if(hasMax && !hasMin){
      return CreatePlanUtil.isInRange(query, 0, 360) ? null : "Enter a valid azimuth";
    }
    else if(hasMax && hasMin){
        return (CreatePlanUtil.isInRange(query, azMin! > azMax! ? 0 : azMin!, 360)) ? null : "Enter a valid maximum azimuth";
    }
    return null;
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

    validFilter['alt'] = false;
    validFilter['az'] = false;

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