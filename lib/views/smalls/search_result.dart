import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';

import '../../models/json_data/skyobj_data.dart';
import '../../models/plan_m.dart';
import '../../util/plan/csv_row.dart';

class SearchResult extends StatefulWidget {
  final int index;

  final SearchViewModel searchVm;
  final CreatePlanViewModel createPlanVm;

  final CsvRow csvData;

  const SearchResult({super.key, required this.index, required this.searchVm, required this.createPlanVm, required this.csvData});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  late Future<SkyObjectData?>? dataFuture;
  Plan? plan;

  @override
  void initState() {
    super.initState();

    if(widget.createPlanVm.lat != null && widget.createPlanVm.lon != null){
      Plan? plan = Plan.fromCsvRow(
        widget.csvData,
        widget.createPlanVm.getStartDateTime,
        widget.createPlanVm.getEndDateTime,
        widget.createPlanVm.lat!,
        widget.createPlanVm.lon!
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
      backgroundColor: (searchVm.selectedResult == csvRow) ? CupertinoColors.activeBlue : CupertinoColors.black,
      onTap: () {
        searchVm.selectResult(csvRow);
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
                return const Text('Has data');
              }
              return const Text('No data');
            },
          )
        ],
      ),
    );
  }
}
