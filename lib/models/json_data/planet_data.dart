import 'package:astro_planner/models/json_data/deepsky_data.dart';

class PlanetData extends DeepskyData{

  final String id = '9c8579b1-71d5-4da9-9c3f-102ddbc5dad8';
  final String secret = '01f3e0ae2dd3b6523d851c884f710d57cdc3e394c976885731416d91aa7bbb1fd4cf11d2ee3647f639c415859b7c02c7d9c28f6bf726aa4e7dd24ef939d5edfa2224d1df4a1310dcc43cf2db3a620102d818d53a18cbb126c8e2525367a89f62fc41dc69dedb230a61167e824e5a1c08';

  PlanetData(
    {required super.hoursVis, required super.hoursSuggested,
      required super.peakTime, required super.name,
      required super.peakBearing, required super.peakAlt
    });
}
