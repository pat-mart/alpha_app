import 'dart:async';
import 'dart:io';

import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:astro_planner/views/screens/empty_modal_sheet.dart';
import 'package:astro_planner/views/screens/plan_sheet_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../models/json_data/skyobj_data.dart';
import '../../models/json_data/weather_data.dart';
import '../../models/plan_m.dart';
import '../../util/plan/cardinal.dart';

class PlanCard extends StatefulWidget {

  final int index;
  final HttpClient httpsClient;

  const PlanCard({super.key, required this.index, required this.httpsClient});

  @override
  State<StatefulWidget> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {

  late Future<WeatherData?> weatherFuture;
  late Future<SkyObjectData?> objFuture;

  final DateFormat dayFormat = DateFormat('EEEE, M/d');
  DateFormat timeFormat = DateFormat('hh:mm');

  late Timer timeToHour;
  late Timer periodicTimer;

  @override
  void initState() {
    super.initState();
    Plan plan = PlanViewModel().getPlan(widget.index);

    weatherFuture = plan.getWeatherData(RequestType.planDuration);

    if(plan.target.isPlanet){
      objFuture = plan.getPlanetInfo(0, widget.httpsClient, plan.timespan.startDateTime, true);
    }
    else {
      objFuture = plan.getDeepSkyInfo(true, 0);
    }

    var diff = plan.timespan.dateTimeRange.end.toUtc().difference(DateTime.timestamp());

    if(!diff.isNegative){
      Timer(diff, (){
        if(mounted) {
          setState(() {});
        }
      });
    }

    timeToHour = Timer(Duration(minutes: 60 - DateTime.now().minute), (){
      periodicTimer = Timer.periodic(const Duration(hours: 1), (timer) {
        if(mounted) {
          setState(() {
            weatherFuture = plan.getWeatherData(
                RequestType.planDuration); // Not sure if this is necessary
          });
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant old){
    super.didUpdateWidget(old);

    Plan plan = PlanViewModel().getPlan(widget.index);

    if(plan.target.isPlanet){
      objFuture = plan.getPlanetInfo(0, widget.httpsClient, plan.timespan.startDateTime, true);
    }

    else {
      objFuture = plan.getDeepSkyInfo(true, 0);
    }

    weatherFuture = plan.getWeatherData(RequestType.planDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Consumer<PlanViewModel>(
        builder: (context, planVm, _) {
          Plan plan = planVm.getPlan(widget.index);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( //Date in EE, MM, d
                plan.timespan.numDays > 1 ? plan.timespan.formattedRange : dayFormat.format(plan.timespan.startDateTime),
                style: const TextStyle(color: CupertinoColors.white, fontSize: 22, fontWeight: FontWeight.bold)
              ),
              Text(
                '${timeFormat.format(plan.timespan.startDateTime.toUtc())} to ${timeFormat.format(plan.timespan.dateTimeRange.end.toUtc())} UTC',
                style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 18)
              ),
              (plan.timespan.dateTimeRange.end.toUtc().isBefore(DateTime.now().toUtc()))
                  ? Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Text('Passed', style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 14)),
                  )
                  : const Text(''),
              const Padding(padding: EdgeInsets.only(bottom: 8)),
              Card(
                color: CupertinoColors.secondarySystemBackground.darkColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: SizedBox (
                  width: double.infinity,
                  height: (MediaQuery.of(context).orientation == Orientation.portrait) ? MediaQuery.of(context).size.height/3: MediaQuery.of(context).size.height/2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(plan.target.properName == '' ? plan.target.catalogName : plan.target.properName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          PullDownButton(
                            itemBuilder: (context) => [
                              PullDownMenuItem(
                                onTap: () {
                                  setState(() {
                                    showCupertinoModalPopup(
                                      context: context,
                                      barrierDismissible: false,
                                      barrierColor: CupertinoColors.darkBackgroundGray,
                                      builder: (context) {
                                        return EmptyModalSheet(child: PlanSheet(planToLoad: plan));
                                      }
                                    );
                                  });
                                },
                                title: 'Edit',
                                icon: CupertinoIcons.pencil
                              ),
                              PullDownMenuItem(
                                onTap: () {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (context) => CupertinoAlertDialog(
                                        title: Text('Delete \'${plan.target.properName == ''
                                            ? plan.target.catalogName
                                            : plan.target.properName}\' plan scheduled for ${plan.formattedStartDate}?'),
                                        content: const Text('This action cannot be undone.'),
                                        actions: [
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: const Text('Cancel'),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          CupertinoDialogAction(
                                            isDestructiveAction: true,
                                            child: const Text('Delete'),
                                            onPressed: () {
                                              planVm.delete(plan.uuid!);
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      )
                                  );
                                },
                                title: 'Delete',
                                isDestructive: true,
                                icon: CupertinoIcons.delete,
                              )
                            ],
                            buttonBuilder: (context, showMenu) => CupertinoButton(onPressed: showMenu, child: const Icon(CupertinoIcons.ellipsis, size: 34))
                          )
                        ]
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 12),
                        child: Text('at latitude ${plan.latitude.toStringAsFixed(3)}° longitude ${plan.longitude.toStringAsFixed(3)}°', style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 24),
                        child: FutureBuilder(
                          future: objFuture,
                          builder: (context, snapshot) {
                            bool usedFilters = plan.azMin != -1 || plan.azMax != -1 || plan.altThresh != -1;
                            String filterMsg = "Not visible within filters";

                            String visibleMsg = "Never visible";
                            String peakMsg = "";

                            if(snapshot.connectionState == ConnectionState.waiting){
                              return const CupertinoActivityIndicator();
                            }

                            if(snapshot.connectionState == ConnectionState.done && snapshot.data == null){
                              return const Text("Error loading data. Please try creating this plan again.", style: TextStyle(color: CupertinoColors.white, fontSize: 16));
                            }

                            else if(snapshot.connectionState == ConnectionState.done
                                && snapshot.data != null
                                && usedFilters && snapshot.data!.hoursSuggested[0].length >= 16){
                              filterMsg = "Within filters from ${snapshot.data!.hoursSuggested[0].substring(11, 16)} to ${snapshot.data!.hoursSuggested[1].substring(11, 16)} UTC";
                            }
                            if(snapshot.data != null && snapshot.data!.hoursVis[0].toString() == "0" && snapshot.data!.hoursVis[1].toString() == "0"){
                              visibleMsg = "Always visible";
                            }

                            if(snapshot.data != null && snapshot.data!.hoursVis[0].toString() != "-1"){ // Planets have different time lengths, going to fix from Flask side at some point
                              if(snapshot.data!.hoursVis[0].toString().length >= 16){
                                visibleMsg = "Visible from ${snapshot.data!.hoursVis[0].toString().substring(11, 16)} to ${snapshot.data!.hoursVis[1].substring(11, 16)} UTC";
                              }
                              else if(snapshot.data!.hoursVis[0].toString().length >= 5){
                                visibleMsg = "Visible from ${snapshot.data!.hoursVis[0].toString().substring(0, 5)} to ${snapshot.data!.hoursVis[1].substring(0, 5)} UTC";
                              }

                              if(snapshot.data!.peakTime.length >= 15 && !snapshot.data!.neverSets){
                                peakMsg = "Peaks ${snapshot.data!.peakAlt.toStringAsFixed(2)}° above (${snapshot.data!.peakBearing.toStringAsFixed(2)}° "
                                    "${Cardinal.getCardinal(snapshot.data!.peakBearing)}) horizon at ${snapshot.data!.peakTime.substring(9, 15)} UTC";
                              }
                            }

                            if(snapshot.data!.hoursVis.contains("-1") || snapshot.data!.hoursVis.contains(-1)){
                              visibleMsg = "Never visible";
                            }
                            else if(snapshot.data!.hoursVis[0] == "0" && snapshot.data!.hoursVis[1] == "0"){
                              visibleMsg = "Always visible";
                            }

                            if(snapshot.hasData && snapshot.data != null){
                              return Column (
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(visibleMsg,
                                        style: TextStyle(color: CupertinoColors.label.darkColor, fontSize: 18)),
                                  ),
                                  (usedFilters) ? Text(filterMsg, style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 16)) : const SizedBox.shrink(),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(peakMsg,
                                        style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 16)),
                                  )
                                ],
                              );
                            }
                            return Text('Observational data unavailable', style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 16));
                          }
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: FutureBuilder(
                          future: weatherFuture,
                          builder: (context, snapshot) {

                            if(snapshot.connectionState == ConnectionState.waiting){
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text('Loading weather data...', style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 14)),
                              );
                            }

                            if(snapshot.data != null && !snapshot.hasError){
                              var data = snapshot.data!;

                              if(data.clearHours.isEmpty && data.hasData){
                                return const Padding(
                                  padding: EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.exclamationmark_triangle, color: CupertinoColors.systemRed),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text('Weather not clear during plan', style: TextStyle(color: CupertinoColors.systemRed, fontSize: 18)),
                                      )
                                    ]
                                  ),
                                );
                              }
                              else if(data.clearHours.isNotEmpty && data.hasData && data.clearHours.length == 1){
                                return Text('Clear at ${data.clearHours[0]}', style: TextStyle(color: CupertinoColors.systemCyan.darkColor, fontSize: 18));
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text('Clear weather from ${timeFormat.format(snapshot.data!.clearHours.first)} to ${timeFormat.format(snapshot.data!.clearHours.last)}',
                                  style: TextStyle(color: CupertinoColors.systemGreen.darkColor, fontSize: 18),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text('Weather data unavailable', style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 14)),
                            );
                          }
                        )
                      ),
                    ],
                  )
                )
              ),
              const Padding(padding: EdgeInsets.only(bottom: 18))
            ],
          );
        } // Consumer function body,
      ),
    );
  }
}
