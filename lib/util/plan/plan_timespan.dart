import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlanTimespan {

  late final DateTime _startDateTime;

  late final DateTime _endDateTime;

  DateTimeRange? _dateRange;

  PlanTimespan(this._startDateTime, this._endDateTime){
    _dateRange = DateTimeRange(
        start: _startDateTime,
        end: _endDateTime
    );
  }

  PlanTimespan.incomplete(this._startDateTime);

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

  DateTimeRange get dateTimeRange => _dateRange!;

  String get formattedRange {
    DateFormat format = DateFormat('E, M/d');

    return '${format.format(_startDateTime)} to ${format.format(_dateRange!.end)}';
  }
}
