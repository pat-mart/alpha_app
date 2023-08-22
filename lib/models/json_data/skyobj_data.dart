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
}
