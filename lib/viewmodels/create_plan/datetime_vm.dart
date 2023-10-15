import 'package:flutter/widgets.dart';

class DateTimeViewModel extends ChangeNotifier {

  static final DateTimeViewModel _instance = DateTimeViewModel._();

  DateTime? startDateTime;

  DateTime? endDateTime;

  DateTime now = DateTime.now();

  DateTimeViewModel._();

  factory DateTimeViewModel(){
    return _instance;
  }

  bool get validStartDate {
    if(startDateTime == null || endDateTime == null){
      return true;
    }
    return startDateTime!.isBefore(endDateTime!);
  }

  bool get canAdd {
    if(startDateTime == null || endDateTime == null){
      return false;
    }
    return validStartDate;
  }

  bool get timesNull{
    return (startDateTime == null || endDateTime == null);
  }

  DateTime get initialStartDate {
    if(startDateTime == null || startDateTime!.isBefore(now)){
      return now;
    }
    return startDateTime!;
  }

  DateTime get initialEndDate {
    if(endDateTime == null || endDateTime!.isBefore(now.add(const Duration(minutes: 1)))){
      return now;
    }
    return endDateTime!;
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

  void setStartDateTime(DateTime date, [bool notify=true]){
    startDateTime = date;
    if(notify) notifyListeners();
  }

  void setEndDateTime(DateTime date, [bool notify=true]){
    endDateTime = date;
    if(notify) notifyListeners();
  }
}

