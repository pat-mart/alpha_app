import '../../util/plan/date.dart';

class SkyObjectData {

  final List<dynamic> hoursVis;
  final List<dynamic> hoursSuggested;

  final String peakTime;
  final String name;

  final double peakBearing;
  final double peakAlt;

  SkyObjectData({
    required this.hoursVis, required this.hoursSuggested,
    required this.peakTime, required this.name,
    required this.peakBearing, required this.peakAlt,
  });

  factory SkyObjectData.fromJson(Map<String, dynamic> json){
    return SkyObjectData(
        hoursVis: json['viewing_hours']['h_visible'],
        hoursSuggested: json['viewing_hours']['h_suggested'],
        peakTime: json['peak']['time'], name: json['obj_name'],
        peakBearing: json['peak']['az'], peakAlt: json['peak']['alt']
    );
  }

  factory SkyObjectData.fromString(String str){

    List<String> paramList = str.split('*');

    return SkyObjectData(
      hoursVis: Date.parseDtString(paramList[0]),
      hoursSuggested: Date.parseDtString(paramList[1]),
      peakTime: paramList[2],
      name: paramList[3],
      peakBearing: double.parse(paramList[4]),
      peakAlt: double.parse(paramList[5])
    );
  }

  @override
  String toString(){
    return '${hoursVis.toString()}*${hoursSuggested.toString()}*$peakTime*$name*$peakBearing*$peakAlt';
  }
}
