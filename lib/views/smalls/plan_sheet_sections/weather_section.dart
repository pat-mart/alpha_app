import 'dart:async';

import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/weather_vm.dart';
import 'package:astro_planner/viewmodels/create_plan_util.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/weather_day.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/json_data/weather_data.dart';
import '../../../util/plan/date.dart';

class WeatherSection extends StatefulWidget {

  final LocationViewModel locationVm;
  final WeatherViewModel weatherVm;

  const WeatherSection({super.key, required this.locationVm, required this.weatherVm});

  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection> with WidgetsBindingObserver {



  Future<WeatherData>? forecastFuture;

  void checkDays() {
    final locationVm = LocationViewModel();

    forecastFuture = CreatePlanUtil.getForecastDays(locationVm.lat, locationVm.lon);
  }


  @override
  void initState() {
    super.initState();
    checkDays();
  }

  @override
  void didUpdateWidget(covariant old){
    super.didUpdateWidget(old);
    checkDays();
  }

  @override
  Widget build(BuildContext context) {

    final locationVm = widget.locationVm;
    final weatherVm = widget.weatherVm;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 10.0),
      height: MediaQuery.of(context).size.height / (MediaQuery.of(context).orientation == Orientation.portrait ? 4 : 2),
      child: Column (
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weather forecast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Image.asset(
                './assets/combined-mark-dark.png',
                scale: 5.5
              )
            ]
          ),
          Expanded(
            child: FutureBuilder(
              future: forecastFuture,
              builder: (context, snapshot) {

                if(snapshot.connectionState == ConnectionState.done && !snapshot.hasError && snapshot.data?.forecastDays != null){
                  weatherVm.dayCache = snapshot.data!.forecastDays;
                }

                return ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                  clipBehavior: Clip.antiAlias,
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Transform.scale(
                      scale: (!locationVm.isValidLocation)
                        ? 1 : (index == weatherVm.selectedIndex ? 1.1 : 0.9),
                      child: CupertinoButton(
                        borderRadius: BorderRadius.zero,
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 30, 0),
                        alignment: Alignment.centerLeft,
                        onPressed: (!locationVm.isValidLocation) ? null : () => weatherVm.onChangeTime(index),
                        child: Text(
                          (locationVm.isValidLocation) ? Date.previewOf(snapshot.data?.forecastDays[index])
                              ?? Date.previewOf(weatherVm.dayCache?[index]) ?? ''
                              : '',
                          style: TextStyle(fontWeight: index == weatherVm.selectedIndex && locationVm.isValidLocation
                              ? FontWeight.bold : FontWeight.normal)
                        ),
                      ),
                    );
                  }
                );
              },
            )
          ),
          Builder(
            builder: (context){
              if(locationVm.isValidLocation){
                return Expanded(child: WeatherDay(weatherVm: weatherVm));
              }
              return Center(
                child: Text(
                  'Enter a valid location to view weather data.',
                  style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray.darkColor)
                )
              );
            }
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Weather times are local to entered location',
                  style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 10),
                  textAlign: TextAlign.start
              ),
              TextButton(
                autofocus: false,
                onPressed: () async {
                  launchUrl(Uri.parse('https://developer.apple.com/weatherkit/data-source-attribution/'));
                },
                child: Text(
                  'Data sources',
                  style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 10, decoration: TextDecoration.underline),
                  textAlign: TextAlign.start
                )
              ),
            ],
          )
        ]
      )
    );
  }
}
