import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PlanSheetHeader extends StatelessWidget {
  const PlanSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {

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
          },
        )
      ),
    );
  }
}


