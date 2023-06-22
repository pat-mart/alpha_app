import 'dart:core';

class SexagesimalCoordinate {
  late int degrees, minutes, seconds;

  SexagesimalCoordinate(this.degrees, this.minutes, this.seconds);

  @override
  String toString() {
    return "$degreesº$minutes'$seconds\"";
  }

  SexagesimalCoordinate setValues(degrees, int minutes, int seconds) {
    this.degrees = degrees;
    this.minutes = minutes;
    this.seconds = seconds;

    return this;
  }
}
