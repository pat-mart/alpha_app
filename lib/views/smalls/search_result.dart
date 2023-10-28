import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';

import '../../models/json_data/skyobj_data.dart';
import '../../models/plan_m.dart';
import '../../models/sky_obj_m.dart';
import '../../util/plan/cardinal.dart';

class SearchResult extends StatefulWidget {
  final int index;

  final SearchViewModel searchVm;
  final LocationViewModel locationVm;
  final DateTimeViewModel dateTimeVm;

  const SearchResult({super.key, required this.index, required this.searchVm, required this.locationVm, required this.dateTimeVm});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  late Future<SkyObjectData?>? dataFuture;
  Plan? plan;

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
      dataFuture = plan.getObjInfo();
    }
    dataFuture = null;
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
          Text(hasCatalogAlias
              ? "${csvRow.catalogName}, ${(csvRow.catalogAlias)} ${(csvRow.isStar) ? csvRow.constellation : ""}"
              : csvRow.catalogName
          ),
          FutureBuilder<SkyObjectData?>(
            future: dataFuture,
            builder: (BuildContext context, objData) {
              if(objData.hasData && objData.data != null){
                if(objData.data!.hoursVis[0] != -1){
                  return const Text('Never visible');
                }
                return Column(
                  children: [
                    Text('Visible from ${objData.data!.hoursVis[0]} to ${objData.data!.hoursVis[1]}'),
                    Text('Peaks ${objData.data!.peakAlt} ${Cardinal.getCardinal(objData.data!.peakBearing)} at ${objData.data!.peakTime}')
                  ]
                );
              }
              return const Text('No data');
            },
          )
        ],
      ),
    );
  }
}
