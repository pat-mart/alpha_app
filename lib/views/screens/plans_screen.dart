import 'package:astro_planner/views/screens/empty_modal_sheet.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/plan_m.dart';
import '../../models/sky_obj_m.dart';
import '../../util/plan/plan_timespan.dart';
import '../../viewmodels/plan_vm.dart';
import '../smalls/plan_sheet_body.dart';
import '../smalls/plan_v.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>{

  late Future<List<Plan>> planListFuture;

  @override
  void initState() {
    super.initState();

    planListFuture = PlanViewModel().savedPlans;
  }

  @override
  Widget build(BuildContext context) {

    final planVm = Provider.of<PlanViewModel>(context);

    return CustomScrollView(
      scrollBehavior: const CupertinoScrollBehavior(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          backgroundColor: CupertinoColors.black,
          largeTitle: const Text('My plans'),
          trailing:
          IconButton(
            icon: const Icon(CupertinoIcons.add_circled, size: 32),
            onPressed: () {
              setState(() {
                showCupertinoModalPopup(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: const Color(0xBB000000),
                  builder: (BuildContext context) {
                    return const EmptyModalSheet(child: PlanSheet());
                  },
                );
              });
            },
          ),
        ),

        SliverToBoxAdapter(
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(left: 14, right: 14),
              child: Consumer<PlanViewModel>(
                builder: (context, planVm, _) => FutureBuilder(
                  future: planListFuture,
                  builder: (context, snapshot) {

                    if(snapshot.connectionState == ConnectionState.done && !snapshot.hasError && snapshot.data != null){
                      planVm.planList = snapshot.data!;
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data == null ? 0 : snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return PlanCard(index: index);
                          }
                      );
                    }
                    else if(snapshot.connectionState == ConnectionState.waiting && !snapshot.hasError){
                      return const CupertinoActivityIndicator();
                    }
                    else {
                      return const Text('Error loading saved plans', style: TextStyle(color: CupertinoColors.white));
                    }
                  }
                )
              )
            )
          )
        )]
    );
  }
}
