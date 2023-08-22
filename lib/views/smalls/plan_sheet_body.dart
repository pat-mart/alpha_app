import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/datetime_section_v.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/plan_sheet_header.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/target_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:astro_planner/views/smalls/plan_sheet_sections/location_section.dart';

class PlanSheet extends StatefulWidget {

  const PlanSheet({super.key});

  @override
  State<StatefulWidget> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet> with SingleTickerProviderStateMixin{

  TextEditingController latController = TextEditingController();
  TextEditingController lonController = TextEditingController();

  late AnimationController animationController;
  late Animation<double> animation;

  TextEditingController altController = TextEditingController();
  TextEditingController azController = TextEditingController();

  @override
  void initState(){
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    latController.dispose();
    lonController.dispose();

    altController.dispose();
    azController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    CreatePlanViewModel createPlanVm = Provider.of<CreatePlanViewModel>(context);

    return CustomScrollView(
      scrollBehavior: const CupertinoScrollBehavior(),
      slivers: <Widget>[
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 10)
          )
        ),
        PlanSheetHeader(createPlanVm: createPlanVm),
        SliverToBoxAdapter(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              LocationSection(latController: latController, lonController: lonController, createPlanVm: createPlanVm),
              const DatetimeSection(),
              TargetSection(createPlanVm: createPlanVm, animationController: animationController, animation: animation),
            ]
          )
        )
      ]
    );
  }
}
