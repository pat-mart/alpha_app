import 'dart:async';
import 'dart:io';

import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';

import '../../models/json_data/skyobj_data.dart';
import '../../models/plan_m.dart';
import '../../util/plan/cardinal.dart';
import '../../viewmodels/create_plan/target_vm.dart';

class SearchResult extends StatefulWidget {
  final int index;
  final int listLength;

  final SearchViewModel searchVm;
  final LocationViewModel locationVm;
  final DateTimeViewModel dateTimeVm;

  final HttpClient httpsClient;

  const SearchResult({super.key, required this.index, required this.listLength, required this.searchVm, required this.locationVm, required this.dateTimeVm, required this.httpsClient});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  late Future<SkyObjectData?>? objDataFuture;

  Plan? plan;

  String getSubtitle(String catalogName){
    final planetNames = ['mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune'];

    final indexes = {0: 'first', 1: 'second', 2: 'fourth', 3: 'fifth', 4: 'sixth', 5: 'seventh', 6: 'eighth'};

    String? index;

    for(int i = 0; i < planetNames.length; i++){
      if(planetNames[i] == catalogName.toLowerCase()){
        index = indexes[i];
        break;
      }
    }

    return index == null ? catalogName : 'The $index planet';
  }

  Future<SkyObjectData?>? get dataFuture {
    final csvData = widget.searchVm.resultsList[widget.index];

    Future<SkyObjectData?>? dataFuture;

    if(widget.locationVm.lat != null && widget.locationVm.lon != null){
      Plan? plan = Plan.fromCsvRow(
          csvData,
          widget.dateTimeVm.startDateTime ?? DateTime.now(),
          widget.dateTimeVm.endDateTime ?? DateTime.now(),
          widget.locationVm.lat!,
          widget.locationVm.lon!
      );
      if(plan.target.isPlanet){
        dataFuture = plan.getPlanetInfo(widget.listLength, widget.httpsClient, widget.dateTimeVm.startDateTime ?? DateTime.now());
      }
      else {
        dataFuture = plan.getDeepSkyInfo(true, 0);
      }

    } else {
      dataFuture = null;
    }

    return dataFuture;
  }

  @override
  void didUpdateWidget(covariant old){
    super.didUpdateWidget(old);

    objDataFuture = dataFuture;
  }

  @override
  void initState() {
    super.initState();

    objDataFuture = dataFuture;
  }

  @override
  void dispose() {
    SearchViewModel().cancelDeadRequests();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final searchVm = widget.searchVm;

    var csvRow = searchVm.resultsList.elementAt(widget.index);

    bool hasProperName = csvRow.properName.isNotEmpty;
    bool hasCatalogAlias = csvRow.catalogAlias.isNotEmpty;

    String properName = csvRow.properName.contains(",")
        ? csvRow.properName.substring(0, csvRow.properName.indexOf(","))
        : csvRow.properName;

    return CupertinoListTile.notched(
      title: Text(hasProperName ? properName : csvRow.catalogName),
      backgroundColor: CupertinoColors.black,
      onTap: () {
        if(searchVm.previewedResult != csvRow || searchVm.previewedResult == null){
          searchVm.previewResult(csvRow);
        }
        else {
          searchVm.deselectResult(csvRow);
        }
      },
      trailing: (searchVm.selectedResult == csvRow || searchVm.previewedResult == csvRow) ? const Icon(CupertinoIcons.check_mark_circled, color: CupertinoColors.activeBlue) : Icon(CupertinoIcons.circle, color: CupertinoColors.inactiveGray.darkColor),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(hasCatalogAlias
                ? "${getSubtitle(csvRow.catalogName)}, ${(csvRow.catalogAlias)} ${(csvRow.isStar) ? csvRow.constellation : ""}"
                : getSubtitle(csvRow.catalogName)
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Builder(
              builder: (context) {
                if(csvRow.isPlanet && csvRow.magnitude != 0.0 || !csvRow.isPlanet){
                  return Text((csvRow.magnitude.isNaN ? 'Unknown magnitude' : 'Magnitude ${csvRow.magnitude.toStringAsFixed(2)}'));
                }
                return const SizedBox.shrink();
              }
            ),
          ),
          FutureBuilder<SkyObjectData?>(
            future: objDataFuture,
            builder: (BuildContext context, objData) {

              if(objData.connectionState == ConnectionState.waiting){
                return const CupertinoActivityIndicator();
              }

              if(objData.hasData && objData.data != null){

                String filterMsg = "Not visible within filters";

                String visibleMsg = "";

                String peakMsg = "";

                if(objData.data!.peakTime.length >= 14){
                  peakMsg = "Peaks ${objData.data!.peakAlt.toStringAsFixed(1)}° above ${Cardinal.getCardinal(objData.data!.peakBearing)} horizon at ${objData.data!.peakTime.substring(9, 14)} UTC";
                }

                if(!objData.data!.hoursVis.contains("-1") || !objData.data!.hoursVis.contains(-1)){ // Planets have different time lengths, going to fix from Flask side at some point
                  if(objData.data!.hoursVis[0].toString().length >= 16){
                    visibleMsg = "Visible from ${objData.data!.hoursVis[0].toString().substring(11, 16)} to ${objData.data!.hoursVis[1].substring(11, 16)} UTC";
                  }
                  else if(objData.data!.hoursVis[0].toString().length >= 5){
                    visibleMsg = "Visible from ${objData.data!.hoursVis[0].toString().substring(0, 5)} to ${objData.data!.hoursVis[1].substring(0, 5)} UTC";
                  }
                }

                if(objData.data!.hoursVis.contains("-1") || objData.data!.hoursVis.contains(-1)){
                  peakMsg = "";
                  visibleMsg = "Never visible";
                }
                else if(objData.data!.hoursVis[0].toString() == "0.0" && objData.data!.hoursVis[1].toString() == "0.0"){
                  visibleMsg = "Always visible";
                }

                if(TargetViewModel().isUsingFilter && !TargetViewModel().validFilter.containsValue(false) && !objData.data!.hoursSuggested.contains(-1)){
                  filterMsg = "Within filters from ${objData.data!.hoursSuggested[0].substring(11, 16)} to ${objData.data!.hoursSuggested[1].substring(11, 15)} UTC";
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visibleMsg),
                    (peakMsg == "") ? const SizedBox.shrink() : Text(peakMsg),
                    (TargetViewModel().isUsingFilter) ? Text(filterMsg) : const SizedBox.shrink()
                  ]
                );
              }
              if(widget.locationVm.lat == null && widget.locationVm.lon == null){
                return const Text('Location needed for observational data');
              }
              return const Text('Data unavailable');
            },
          )
        ],
      ),
    );
  }
}
