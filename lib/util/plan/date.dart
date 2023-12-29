import 'dart:math';

import 'package:alpha_lib/alpha_lib.dart';
import 'package:intl/intl.dart';

sealed class Date {
  static DateFormat prevFormat = DateFormat('EE d');

  static final timeFormat = DateFormat('y-M-d H:mm');

  static String? previewOf(DateTime? dt) {
    if (dt == null) {
      return null;
    }
    return prevFormat.format(dt);
  }

  static String formatInt(int hour) {
    return hour.toString().padLeft(2, '0');
  }

  static List<DateTime> parseDtString(String str) {
    List<DateTime> dtList = List.empty(growable: true);
    List<String> trimmed = str.substring(1, str.length - 1).split(', ');

    for (String dt in trimmed) {
      dtList.add(DateTime.parse(dt));
    }

    return dtList;
  }

  static dynamic hourToDt(DateTime startDate, double hour,
      [double utcOffset = 0]) {
    if (hour == -1.0) {
      return hour;
    }

    if (hour < 0) {
      hour += (24 * (pi / 12));
    } else if (hour > 24) {
      hour -= (24 * (pi / 12));
    }

    hour = hour.toHours(Units.radians);

    final int startHour = (hour + utcOffset).floor();
    final int startMinute = ((hour - startHour) * 60).floor();

    return DateTime.utc(
        startDate.year, startDate.month, startDate.day, startHour, startMinute);
  }

  static List<dynamic> hoursToDtList(DateTime startDate, List<double> hours,
      [double utcOffset = 0]) {
    if (hours.contains(-1)) {
      return [-1, -1];
    } else if (hours[0] == 0.0 && hours[1] == 0.0) {
      return hours;
    }

    final start = hourToDt(startDate, hours[0]);
    final end = hourToDt(startDate, hours[1]);

    if (start == -1 || end == -1) {
      return [-1, -1];
    }

    return [start, end];
  }

  static List<dynamic> dtToStringList(List<dynamic>? list) {
    if (list == null || list.contains(-1)) {
      return [-1, -1];
    } else if (list == [0, 0]) {
      return list;
    } else {
      return [timeFormat.format(list[0]), timeFormat.format(list[1])];
    }
  }
}
