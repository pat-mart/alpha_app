import 'package:intl/intl.dart';

sealed class Date {

  static DateFormat prevFormat = DateFormat('EE d');

  static String? previewOf(DateTime? dt) {
    if(dt == null){
      return null;
    }
    return prevFormat.format(dt);
  }

  static String formatInt(int hour){
    return hour.toString().padLeft(2, '0');
  }

  static List<DateTime> parseDtString(String str){
    List<DateTime> dtList = List.empty(growable: true);
    List<String> trimmed = str.substring(1, str.length-1).split(', ');

    for(String dt in trimmed){
      dtList.add(DateTime.parse(dt));
    }

    return dtList;
  }
}
