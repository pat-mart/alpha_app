import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';

import '../../models/json_data/skyobj_data.dart';
import '../../models/plan_m.dart';

class SearchResult extends StatefulWidget {
  final int index;
  const SearchResult({super.key, required this.index});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  @override
  Widget build(BuildContext context) {

    SearchViewModel vm = SearchViewModel();
    var instance = vm.resultsList.elementAt(widget.index);

    bool hasProperName = instance.properName.isNotEmpty;
    bool hasCatalogAlias = instance.catalogAlias.isNotEmpty;

    return CupertinoListTile.notched(
      title: Text(hasProperName ? instance.properName : instance.catalogName),
      subtitle: Text(hasCatalogAlias
          ? "${instance.catalogName}, ${instance.catalogAlias}"
          : instance.catalogName
      )
      // subtitle: FutureBuilder(
      //   future: objDataFuture,
      //   builder: (BuildContext context, objData) {
      //     if(objData.hasData){
      //       if(objData.data?.hoursVis[0] == -1){
      //         return const Text("Not observable");
      //       }
      //       else {
      //         return Text("Visible from ${objData.data!.hoursVis[0]} to ${objData.data!.hoursVis[1]}");
      //       }
      //     }
      //     return const Text('Data unavailable');
      //   },
      // ),
    );
  }
}
