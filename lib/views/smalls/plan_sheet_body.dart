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

class _PlanSheetState extends State<PlanSheet> with SingleTickerProviderStateMixin, WidgetsBindingObserver{

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState(){
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
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
              LocationSection(createPlanVm: createPlanVm),
              const DatetimeSection(),
              TargetSection(createPlanVm: createPlanVm, animationController: animationController, animation: animation),
            ]
          )
        )
      ]
    );
  }
}
