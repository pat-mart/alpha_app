import 'package:astro_planner/models/plan_m.dart';
import 'package:astro_planner/views/screens/plan_sheet.dart';
import 'package:astro_planner/views/smallwidgets/plan_v.dart';

import 'package:flutter/material.dart';
import '../../viewmodels/list_vm.dart';
import '../../viewmodels/plan_vm.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>{

  final PlanViewModel planVm = PlanViewModel();
  final ListViewModel<Plan> listViewModel = ListViewModel();

  void refresh(){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(left: 12, right: 12, top: 100),
            child: Column(
                children: <Widget>[
                  Row( //Header with button
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('My Plans', style: TextStyle(fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                      IconButton(
                        onPressed: () =>
                          setState(() {
                            showModalBottomSheet(
                              backgroundColor: const Color(0xFF2E2E2E),
                              context: context,
                              isDismissible: false,
                              barrierColor: const Color(0x67000000),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                              ),
                              builder: (BuildContext context) => Wrap(
                                children: <Widget>[
                                  PlanSheet(onAddPlan: () => setState(() {
                                    refresh();
                                  }))
                                ])
                            );
                          }),
                        style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                Colors.white)),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                            Icons.add_circle_outline, color: Colors.white,
                            size: 36),
                      )
                    ],
                  ),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: planVm.planList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return PlanCard(
                            plan: planVm.planList.elementAt(index),
                            onDelete: () => setState(() => planVm.removeObject(index))
                        );
                      }
                  )
                ]
            ),
          )
      );
  }
}
