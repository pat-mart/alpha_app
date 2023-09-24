import 'dart:async';

import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/weather_vm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

import '../../../models/json_data/weather_data.dart';
import '../../../models/plan_m.dart';
import '../../../util/plan/date.dart';

class WeatherDay extends StatefulWidget {

  final WeatherViewModel weatherVm;

  const WeatherDay({super.key, required this.weatherVm});

  @override
  State<WeatherDay> createState() => _WeatherDayState();
}

class _WeatherDayState extends State<WeatherDay> {

  Future<WeatherData?>? weatherFuture;

  late final StreamSubscription<ConnectivityResult> subscription;

  Icon getWeatherIcon(String condition, bool isDay) {

    Map<String, Icon> iconMap = {
      'Clear': Icon(!isDay ? CupertinoIcons.moon_stars : CupertinoIcons.sun_max, color: CupertinoColors.white),
      'Cloudy':  const Icon(CupertinoIcons.cloud, color: CupertinoColors.white),
      'PartlyCloudy': Icon(!isDay ? CupertinoIcons.cloud_sun : CupertinoIcons.cloud_moon, color: CupertinoColors.white),
      'MostlyCloudy': const Icon(CupertinoIcons.cloud, color: CupertinoColors.white),
      'Drizzle':  const Icon(CupertinoIcons.cloud_drizzle, color: CupertinoColors.white),
      'HeavyRain': const Icon(CupertinoIcons.cloud_heavyrain, color: CupertinoColors.white),
      'Hail':  const Icon(CupertinoIcons.cloud_hail, color: CupertinoColors.white),
      'Tornado': const Icon(CupertinoIcons.tornado, color: CupertinoColors.white),
      'Hurricane': const Icon(CupertinoIcons.hurricane, color: CupertinoColors.white),
      'TropicalStorm': const Icon(CupertinoIcons.tropicalstorm, color: CupertinoColors.white)
    };

    if(!iconMap.containsKey(condition)){
      if(['Rain', 'Showers', 'ScatteredShowers'].contains(condition)){
        return const Icon(CupertinoIcons.cloud_rain, color: CupertinoColors.white);
      }

      else if(condition.contains('Thunder')){
        return const Icon(CupertinoIcons.cloud_bolt, color: CupertinoColors.white);
      }

      else if(['Fog', 'Haze'].contains(condition)){
        return const Icon(CupertinoIcons.cloud_fog, color: CupertinoColors.white);
      }

      else if(['Smoke', 'Dust'].contains(condition)){
        return const Icon(CupertinoIcons.smoke, color: CupertinoColors.white);
      }

      else if(condition.contains('Snow') || condition == 'Blizzard'){
        return const Icon(CupertinoIcons.cloud_snow, color: CupertinoColors.white);
      }

      else if(condition.contains('Sleet') || condition.contains('Freezing') || condition.contains('Mixed')){
        return const Icon(CupertinoIcons.cloud_sleet, color: CupertinoColors.white);
      }
      return const Icon(CupertinoIcons.cloud, color: CupertinoColors.white);
    }
    return iconMap[condition]!;
  }

  void initFuture() {

    final locationVm = LocationViewModel();

    if(locationVm.lat != null && locationVm.lon != null){
      final instance = WeatherViewModel();
      if(instance.dataCache.containsKey(instance.selectedIndex) && instance.dataCache[instance.selectedIndex] != null) {
        weatherFuture = instance.dataCache[instance.selectedIndex];
        return;
      }
      weatherFuture = Plan.onlyLocation(locationVm.lat!, locationVm.lon!).getWeatherData();
      WeatherViewModel().cacheData(weatherFuture, instance.selectedIndex);
    }
    else {
      weatherFuture = null;
    }
  }

  @override
  void initState(){
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result){
      if([ConnectivityResult.wifi, ConnectivityResult.ethernet, ConnectivityResult.mobile, ConnectivityResult.other].contains(result)){
        widget.weatherVm.clearCaches();
      }
    });

    initFuture();
  }

  @override
  void didUpdateWidget(covariant old){
    super.didUpdateWidget(old);

    initFuture();
  }

  @override
  void dispose(){
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: weatherFuture,
      builder: (BuildContext context, snapshot) {

        final weatherVm = widget.weatherVm;

        if(snapshot.hasError){
          weatherVm.dataCache.remove(weatherVm.selectedIndex);
        }

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CupertinoActivityIndicator(radius: 10));
        }
        if(snapshot.hasData) {
          var weatherList = snapshot.data!.weatherList;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.hoursToDisplay[widget.weatherVm.selectedIndex].length,
            itemBuilder: (BuildContext context, int index) {
              final node = weatherList[widget.weatherVm.selectedIndex][index];
              return Column(
                children: [
                  SizedBox(height: 20, child: getWeatherIcon(node.condition, node.isDay)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Date.formatInt(snapshot.data!.hoursToDisplay[widget.weatherVm.selectedIndex][index]),
                      style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor),
                    )
                  )
                ],
              );
            },
          );
        }
        else {
          return Center(
            child: Text(
              'Unable to load weather data. This could be a problem with Apple Weather.',
              style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray.darkColor)
            )
          );
        }
      },
    );
  }
}
