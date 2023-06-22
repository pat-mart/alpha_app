import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/models/sky_object_m.dart';

import 'package:astro_planner/util/catalog_types.dart';
import 'package:astro_planner/views/smallwidgets/plan_v.dart';

import 'package:flutter/material.dart';

import '../../util/catalog_name.dart';
import '../../util/telescope.dart';
import '../../viewmodels/plan_vm.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>{

  final PlanViewModel planVm = PlanViewModel();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(right: 14, left: 14, top: 100),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row( //Header with button
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('My Plans', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton (
                    onPressed: () => setState(() {
                      planVm.addPlan(
                        SkyObject('Orion Nebula', CatalogName(CatalogTypes.messier, 31)),
                        SetupModel('Setup 1', Telescope('WO Z61', 61, 360), 1.6, true, true)
                      );
                    }),
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.black)),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 36),
                  )],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: planVm.planList.length,
                itemBuilder: (BuildContext context, int index){
                  return PlanCard(plan: planVm.planList.elementAt(index));
                })
            ]
          ),
        )
    );
  }
}
