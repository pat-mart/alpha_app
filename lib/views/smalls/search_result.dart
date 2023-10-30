import 'dart:io';

import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';

import '../../models/json_data/skyobj_data.dart';
import '../../models/plan_m.dart';
import '../../util/plan/cardinal.dart';

class SearchResult extends StatefulWidget {
  final int index;
  final int listLength;

  final SearchViewModel searchVm;
  final LocationViewModel locationVm;
  final DateTimeViewModel dateTimeVm;

  final DateTime timestamp;

  const SearchResult({super.key, required this.index, required this.listLength, required this.searchVm, required this.locationVm, required this.dateTimeVm, required this.timestamp});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  late Future<SkyObjectData?>? dataFuture;

  final httpsClient = HttpClient();

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

  @override
  void initState() {
    super.initState();

    final csvData = widget.searchVm.resultsList[widget.index];

    if(widget.locationVm.lat != null && widget.locationVm.lon != null){
      Plan? plan = Plan.fromCsvRow(
        csvData,
        widget.dateTimeVm.startDateTime ?? DateTime.now(),
        widget.dateTimeVm.endDateTime ?? DateTime.now(),
        widget.locationVm.lat!,
        widget.locationVm.lon!
      );
      dataFuture = plan.getObjInfo(widget.listLength, widget.index, httpsClient);
    } else {
      dataFuture = null;
    }
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
      backgroundColor: (searchVm.previewedResult == csvRow) ? CupertinoColors.activeBlue : CupertinoColors.black,
      onTap: () {
        searchVm.previewResult(csvRow);
      },
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
          FutureBuilder<SkyObjectData?>(
            future: dataFuture,
            builder: (BuildContext context, objData) {
              if(objData.hasData && objData.data != null){
                if(objData.data!.hoursVis[0] == -1){
                  return const Text('Never visible');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visible from ${(objData.data!.hoursVis[0] as String).substring(0, 5)} to ${(objData.data!.hoursVis[1] as String).substring(0, 5)}'),
                    Text('Peaks (${objData.data!.peakAlt}°, ${objData.data!.peakBearing.toStringAsFixed(2)}°) (${Cardinal.getCardinal(objData.data!.peakBearing)}) at ${objData.data!.peakTime.substring(5, 16)}')
                  ]
                );
              }
              else if(objData.connectionState == ConnectionState.waiting){
                return const CupertinoActivityIndicator();
              }
              if(widget.locationVm.lat == null && widget.locationVm.lon == null){
                return const Text('Location needed for observational data');
              }
              print(objData.error);
              return const Text('Data unavailable');
            },
          )
        ],
      ),
    );
  }
}
