import 'package:astro_planner/viewmodels/plan_vm.dart';
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

  late Future<SkyObjectData> objDataFuture;

  @override void initState() {
    super.initState();
    Plan plan = PlanViewModel().getPlan(widget.index);

    objDataFuture = plan.getObjInfo();
  }

  @override
  Widget build(BuildContext context) {
    Plan plan = PlanViewModel().getPlan(widget.index);

    return CupertinoListTile(
      title: Text(plan.target.name),
      subtitle: FutureBuilder(
        future: objDataFuture,
        builder: (BuildContext context, objData) {
          if(objData.hasData){
            if(objData.data?.hoursVis[0] == -1){
              return const Text("Not observable");
            }
            else {
              return Text("Visible from ${objData.data!.hoursVis[0]} to ${objData.data!.hoursVis[1]}");
            }
          }
          return const Text('Data unavailable');
        },
      ),
    );
  }
}
