import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlanSheetHeader extends StatelessWidget {
  const PlanSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column (
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<CreatePlanViewModel>(
              builder: (context, createPlanVm, _) => CupertinoButton(
                  padding: const EdgeInsets.only(left: 14, top: 14), // "negates" leftward margin
                  child: const Icon(CupertinoIcons.xmark_circle, size: 36, color: CupertinoColors.systemGrey),
                  onPressed: () {
                    Navigator.pop(context); // FIXME add dialog
                  }
              ),
            )
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Add new plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
            )
          ],
        ),
      ],
    );
  }
}

