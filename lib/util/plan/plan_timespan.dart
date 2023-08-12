import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlanTimespan {

  late final DateTime _startDateTime;

  late final Duration _imagingDuration;

  late DateTimeRange _dateRange;

  final List<String> _daysOfWeek = [];

  PlanTimespan(this._startDateTime, this._imagingDuration){
    _dateRange = DateTimeRange(
        start: _startDateTime,
        end: _startDateTime.add(_imagingDuration)
    );
    _daysOfWeek.add(DateFormat('EEEE').format(_startDateTime));
    _daysOfWeek.add(DateFormat('EEEE').format(_dateRange.end));
  }

  // Working as of 7/4/23
  int get numDays {
    if(dateTimeRange.end.day == _startDateTime.day){
      return 1;
    }
    else if(dateTimeRange.end.difference(_startDateTime).inDays == 0){
      return 2;
    }
    else {
      return dateTimeRange.end.difference(_startDateTime).inDays + 2;
    }
  } //Finds days between start & end

  DateTime get startDateTime => _startDateTime;

  DateTimeRange get dateTimeRange => _dateRange;

  String get formattedRange {
    DateFormat format = DateFormat('EEEE, MMMM d');

    return '${format.format(_startDateTime)} to ${format.format(_dateRange.end)}';
  }
}
