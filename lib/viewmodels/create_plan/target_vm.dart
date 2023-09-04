import 'package:flutter/cupertino.dart';

import '../create_plan_util.dart';

class TargetViewModel extends ChangeNotifier {

  bool _isUsingFilter = false;

  double? _altFilter = -1;
  double? _azFilter = -1;

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

  String? azValidator(String? query){
    if(CreatePlanUtil.isInRange(query, 0, 360)){
      validFilter['az'] = true;
      return null;
    }
    validFilter['az'] = false;
    return "Enter a valid azimuth";
  }

  void onChangeAltFilter(String newValue){
    _altFilter = CreatePlanUtil.onChangeDegree(newValue);
  }

  void onChangeAzFilter(String newValue){
    _azFilter = CreatePlanUtil.onChangeDegree(newValue);
  }

  void clearFilters(){
    _altFilter = null;
    _azFilter = null;

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

  set usingFilter(newVal){
    _isUsingFilter = newVal;
    notifyListeners();
  }

  bool get isUsingFilter => _isUsingFilter;
}