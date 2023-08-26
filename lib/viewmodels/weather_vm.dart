import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class WeatherViewModel extends ChangeNotifier {

  DateTime _min = DateTime.now();
  DateTime _max = DateTime.now().add(const Duration(days: 9));

  DateTime _selectedDateTime = DateTime.now();
  final DateFormat _dateFormat = DateFormat('EE, MMMM d');

  static final WeatherViewModel instance = WeatherViewModel._();

  factory WeatherViewModel(){
    return instance;
  }

  WeatherViewModel._();

  String getFormattedDate() {
    return _dateFormat.format(_selectedDateTime);
  }

  void onChangeTime (DateTime newTime) {
    _selectedDateTime = newTime;
    notifyListeners();
  }

  DateTime get minDateTime {
    _min = DateTime.now();
    return _min;
  }

  DateTime get maxDateTime {
    _max = DateTime.now().add(const Duration(days: 9));
    return _max;
  }

}
