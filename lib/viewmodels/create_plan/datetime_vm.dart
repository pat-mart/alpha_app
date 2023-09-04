import 'package:flutter/widgets.dart';

class DateTimeViewModel extends ChangeNotifier {

  static final DateTimeViewModel _instance = DateTimeViewModel._();

  DateTime? _startDateTime;

  DateTime? _endDateTime;

  DateTime now = DateTime.now();

  DateTimeViewModel._();

  factory DateTimeViewModel(){
    return _instance;
  }

  bool get validStartDate {
    if(_startDateTime == null || _endDateTime == null){
      return true;
    }
    return _startDateTime!.isBefore(_endDateTime!);
  }

  bool get canAdd {
    if(_startDateTime == null || _endDateTime == null){
      return false;
    }
    return validStartDate;
  }

  bool get timesNull{
    return (_startDateTime == null || _endDateTime == null);
  }

  DateTime get initialStartDate {
    if(_startDateTime == null || _startDateTime!.isBefore(now)){
      return now;
    }
    return _startDateTime!;
  }

  DateTime get initialEndDate {
    if(_endDateTime == null || _endDateTime!.isBefore(now.add(const Duration(minutes: 1)))){
      return now;
    }
    return _endDateTime!;
  }

  void clearControllers(textEditingControllers){
    for(TextEditingController c in textEditingControllers){
      c.clear();
    }
    notifyListeners();
  }

  void setNow() {
    now = DateTime.now();
    notifyListeners();
  }

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

