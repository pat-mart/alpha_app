import '../plan_m.dart';

class DeepskyData {

  final List<dynamic> hoursVis;
  final List<dynamic> hoursSuggested;

  final String peakTime;
  final String name;

  final double peakBearing;
  final double peakAlt;

  DeepskyData({
    required this.hoursVis, required this.hoursSuggested,
    required this.peakTime, required this.name,
    required this.peakBearing, required this.peakAlt
  });

  factory DeepskyData.fromJson(Map<String, dynamic> json, Plan plan){
    return DeepskyData(
        hoursVis: json['viewing_hours']['h_visible'],
        hoursSuggested: json['viewing_hours']['h_suggested'],
        peakTime: json['peak']['time'], name: json['obj_name'],
        peakBearing: json['peak']['az'], peakAlt: json['peak']['alt']
    );
  }
}
