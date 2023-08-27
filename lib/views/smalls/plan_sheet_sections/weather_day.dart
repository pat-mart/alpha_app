import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:astro_planner/viewmodels/weather_vm.dart';
import 'package:flutter/cupertino.dart';

import '../../../models/json_data/weather_data.dart';
import '../../../models/plan_m.dart';

class WeatherDay extends StatefulWidget {

  final WeatherViewModel weatherVm;
  final CreatePlanViewModel createPlanVm;

  const WeatherDay({super.key, required this.weatherVm, required this.createPlanVm});

  @override
  State<WeatherDay> createState() => _WeatherDayState();
}

class _WeatherDayState extends State<WeatherDay> {

  Future<WeatherData>? weatherFuture;

  void initFuture() {
    if(widget.createPlanVm.lat != null && widget.createPlanVm.lon != null){
      weatherFuture = Plan.onlyLocation(widget.createPlanVm.lat!, widget.createPlanVm.lon!).getWeatherData();
    }
    else {
      weatherFuture = null;
    }
  }

  @override
  void initState() {
    super.initState();
    initFuture();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    initFuture();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: weatherFuture,
      builder: (BuildContext context, snapshot) {
        if(weatherFuture != null && snapshot.hasData) {
          return Column(
            children: [
              const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),

            ],
          );
        }
        else if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
              child: Text(
                'Loading weather information...',
                style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray.darkColor)
              )
          );
        }
        else if(snapshot.hasError) {
          return Center(
            child: Text(
              'Unable to load weather data. Check your internet connection.',
              style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray.darkColor)
            )
          );
        }
        else {
          return Center(
            child: Text(
              'Enter a valid location to view weather data.',
              style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray.darkColor)
            )
          );
        }
      },
    );
  }
}
