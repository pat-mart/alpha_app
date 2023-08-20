import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlanSheetHeader extends StatefulWidget {
  final CreatePlanViewModel createPlanVm;

  const PlanSheetHeader({super.key, required this.createPlanVm});

  @override
  State<PlanSheetHeader> createState() => _PlanSheetHeaderState();
}

class _PlanSheetHeaderState extends State<PlanSheetHeader> {
  @override
  Widget build(BuildContext context) {
    final createPlanVm = widget.createPlanVm;
    return CupertinoSliverNavigationBar(
      automaticallyImplyLeading: false,
      largeTitle: const Text('New plan'),
      trailing: Material(
        type: MaterialType.transparency,
        borderOnForeground: true,
        child: IconButton(
          padding: const EdgeInsets.only(left: 20),
          icon: const Icon(
            CupertinoIcons.xmark_circle_fill,
            color: CupertinoColors.systemGrey,
            size: 32,
          ),
          onPressed: () {
            Navigator.pop(context);
            createPlanVm.clearFilters();
            createPlanVm.usingFilter = false;
          },
        )
      ),
    );
  }
}


