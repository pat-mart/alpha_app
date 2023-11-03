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

    final indexes = {1: 'first', 2: 'second', 3: 'third', 4: 'fourth', 5: 'fifth', 6: 'sixth', 7: 'seventh', 8: 'eighth', 9: 'ninth'};

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
      dataFuture = plan.getObjInfo(widget.listLength, widget.index, widget.httpsClient, widget.dateTimeVm.startDateTime ?? DateTime.now());
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
            child: Text((csvRow.magnitude.isNaN ? 'Unknown magnitude' : 'Magnitude ${csvRow.magnitude}')),
          ),
          FutureBuilder<SkyObjectData?>(
            future: objDataFuture,
            builder: (BuildContext context, objData) {

              if(objData.hasData && objData.data != null){
                String filterMsg = "Not visible within filters";
                if(TargetViewModel().isUsingFilter && !TargetViewModel().validFilter.containsValue(false) && objData.data!.hoursSuggested.length >= 2){
                  filterMsg = "Within filters from ${objData.data!.hoursSuggested[0].substring(12, 17)} to ${objData.data!.hoursSuggested[1].substring(12, 17)}";
                }
                if(objData.data!.hoursVis[0] == -1){
                  return const Text('Never visible');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visible from ${(objData.data!.hoursVis[0] as String).substring(0, 5)} to ${(objData.data!.hoursVis[1] as String).substring(0, 5)}'),
                    Text('Peaks (${objData.data!.peakAlt}°, ${objData.data!.peakBearing.toStringAsFixed(2)}°) (${Cardinal.getCardinal(objData.data!.peakBearing)}) at ${objData.data!.peakTime.substring(5, 16)}'),
                    (TargetViewModel().isUsingFilter) ? Text(filterMsg) : const SizedBox.shrink()
                  ]
                );
              }
              else if(objData.connectionState == ConnectionState.waiting || objData.connectionState == ConnectionState.active){
                return const CupertinoActivityIndicator();
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
