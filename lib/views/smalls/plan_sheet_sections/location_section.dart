import 'dart:async';

import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

import '../../../viewmodels/create_plan/weather_vm.dart';
import '../../../viewmodels/create_plan_util.dart';

class LocationSection extends StatefulWidget {
  final LocationViewModel locationVm;
  final WeatherViewModel weatherVm;

  const LocationSection({super.key, required this.locationVm, required this.weatherVm});

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> with WidgetsBindingObserver {

  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();

  late Future<bool> locationPermissionFuture;
  late Future<bool> internetFuture;

  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    locationPermissionFuture = widget.locationVm.hasLocationPermission();
    internetFuture = CreatePlanUtil.hasInternetConnection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {

    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.resumed){
      await LocationViewModel().location;

      if(CreatePlanUtil.isNumeric(latController.text)){
        widget.locationVm.onChangeLat(latController.text);
      }
      if(CreatePlanUtil.isNumeric(lonController.text)){
        widget.locationVm.onChangeLon(lonController.text);
      }

      if(!widget.locationVm.serviceEnabled && widget.locationVm.isUsingService){
        widget.locationVm.clearControllers([lonController, latController]);
        widget.locationVm.nullCoordinates();
      }
    }
  }

  @override
  void dispose() {

    latController.dispose();
    lonController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationVm = widget.locationVm;
    final weatherVm = widget.weatherVm;

    return FutureBuilder(
      future: internetFuture,
      builder: (context, internetSnapshot) {

        if(internetSnapshot.hasData){
          locationVm.hasInternet = internetSnapshot.data!;
        }
        else if(internetSnapshot.data == null){
          locationVm.hasInternet = false;
        }

        return CupertinoFormSection.insetGrouped(
          margin: EdgeInsets.zero,
          header: const Text('LOCATION'),
          children: [
            FutureBuilder(
              future: locationPermissionFuture,
              builder: (context, snapshot) {

                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CupertinoActivityIndicator(radius: 10));
                }

                return CupertinoFormRow(
                  prefix: Text('Use this location', style: TextStyle(color: locationVm.serviceEnabled ? CupertinoColors.white : CupertinoColors.inactiveGray.darkColor)),
                  helper: !locationVm.serviceEnabled ? Text('Location permission denied', style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray.darkColor)) : null,
                  child: CupertinoSwitch(
                    onChanged: (newVal) async { // DO NOT TOUCH
                      await locationVm.hasLocationPermission();

                      if(!locationVm.serviceEnabled){
                        locationVm.usingService = false;
                        return;
                      }

                      locationVm.usingService = newVal;

                      if(newVal){
                        latController.clear();
                        lonController.clear();

                        await locationVm.location;
                      }
                      else if(!newVal){
                        locationVm.nullCoordinates();
                      }
                      weatherVm.clearCaches();
                    },
                    activeColor: CupertinoColors.activeGreen,
                    value: locationVm.isUsingService && locationVm.serviceEnabled,
                  )
                );
              },
            ),
            CupertinoTextFormFieldRow(
                key: const Key('Latitude'),
                controller: latController,
                onChanged: (String newVal) {
                  locationVm.onChangeLat(newVal);
                  if(internetSnapshot.hasData && internetSnapshot.data == true){
                    WeatherViewModel().clearCaches();
                  }
                },
                validator: locationVm.latValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                prefix: Padding(
                    padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/2.5),
                    child: const Text('Latitude   ')
                ),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                placeholder: (locationVm.serviceEnabled && locationVm.isUsingService && locationVm.locationData != null) ? '${locationVm.locationData?.latitude?.toStringAsFixed(4) ?? 0.000}°' : '0.000°...',
                enabled: !locationVm.isUsingService,

                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                autocorrect: false
            ),
            CupertinoTextFormFieldRow(
                key: const Key('Longitude'),
                controller: lonController,
                onChanged: (String newVal) {
                  locationVm.onChangeLon(newVal);
                  if(internetSnapshot.hasData && internetSnapshot.data == true){
                    WeatherViewModel().clearCaches();
                  }
                },
                validator: locationVm.lonValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                prefix: Padding(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/2.5),
                  child: const Text('Longitude'),
                ),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                placeholder: (locationVm.serviceEnabled && locationVm.isUsingService && locationVm.locationData != null) ? '${locationVm.locationData?.longitude?.toStringAsFixed(4) ?? 0.000}°'  : '0.000°...',
                enabled: !locationVm.isUsingService,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                autocorrect: false
            )
          ]
        );
      }
    );
  }
}
