import 'package:astro_planner/views/screens/sheet.dart';
import 'package:astro_planner/views/smallwidgets/plan_sheet_body.dart';
import 'package:astro_planner/views/smallwidgets/plan_v.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/plan_vm.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>{

  final PlanViewModel planVm = PlanViewModel();

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: CupertinoColors.black,
            padding: EdgeInsetsDirectional.zero,
            largeTitle: const Text('My plans'),
            leading: const Icon(Icons.add_circle_outline),
            trailing: IconButton(
              icon: const Icon(CupertinoIcons.add_circled, size: 36),
              onPressed: () {
                setState(() {
                  showCupertinoModalPopup(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: const Color(0xBB000000),
                    builder: (BuildContext context) {
                      return Sheet(child: PlanSheet(onAddPlan: refresh));
                    }
                  );
                });
              },
            ),
          ),

          SliverFillRemaining(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: planVm.modelList.length,
              itemBuilder: (BuildContext context, int index) {
                return PlanCard(
                  plan: planVm.modelList.elementAt(index),
                  onDelete: () => setState(() => planVm.removeModelAt(index))
                );
              }
            ),
          )]
      ),
    );
  }
}
