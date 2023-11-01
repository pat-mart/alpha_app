import '../../util/plan/date.dart';

class SkyObjectData {

  final List<dynamic> hoursVis;
  final List<dynamic> hoursSuggested;

  final String peakTime;
  final String name;

  final double peakBearing;
  final double peakAlt;

  final DateTime dateEntered;

  SkyObjectData({
    required this.hoursVis, required this.hoursSuggested,
    required this.peakTime, required this.name,
    required this.peakBearing, required this.peakAlt,
    required this.dateEntered
  });

  factory SkyObjectData.fromJson(Map<String, dynamic> json, DateTime dateEntered){
    return SkyObjectData(
        hoursVis: json['viewing_hours']['h_visible'],
        hoursSuggested: json['viewing_hours']['h_suggested'],
        peakTime: json['peak']['time'], name: json['obj_name'],
        peakBearing: json['peak']['az'], peakAlt: json['peak']['alt'],
        dateEntered: dateEntered
    );
  }

  factory SkyObjectData.fromString(String str){

    List<String> paramList = str.split('*');

    return SkyObjectData(
      hoursVis: paramList[0].split(','),
      hoursSuggested: paramList[1].split(','),
      peakTime: paramList[2],
      name: paramList[3],
      peakBearing: double.parse(paramList[4]),
      peakAlt: double.parse(paramList[5]),
      dateEntered: DateTime.parse(paramList[6])
    );
  }

  @override
  String toString(){
    return '${hoursVis.toString()}*${hoursSuggested.toString()}*$peakTime*$name*$peakBearing*$peakAlt*$dateEntered';
  }
}
