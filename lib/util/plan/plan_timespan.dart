import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlanTimespan {

  late final DateTime _startDateTime;

  late final Duration _imagingDuration;

  late DateTimeRange _dateTimeRange;

  final List<String> _daysOfWeek = [];

  PlanTimespan(this._startDateTime, this._imagingDuration){
    _dateTimeRange = DateTimeRange(
        start: _startDateTime,
        end: _startDateTime.add(_imagingDuration)
    );
    _daysOfWeek.add(DateFormat('EEEE').format(_startDateTime));
    _daysOfWeek.add(DateFormat('EEEE').format(_dateTimeRange.end));
  }

  DateTime get startDate => _startDateTime;

  DateTimeRange get dateRange => _dateTimeRange;

  List<String> get daysOfWeek => _daysOfWeek;
}
