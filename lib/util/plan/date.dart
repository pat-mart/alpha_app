import 'package:intl/intl.dart';

abstract class Date {

  static DateFormat prevFormat = DateFormat('EE d');

  static String previewOf(DateTime dt) {
    return prevFormat.format(dt);
  }

  static DateTime get current {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime get max {
    return current.add(const Duration(days: 1));
  }

  static List<DateTime> get forecastDays {
    List<DateTime> days = [];
    for(int i = 0; i < 2; i++){
      days.add(Date.current.add(Duration(days: i)));
    }
    return days;
  }
}
