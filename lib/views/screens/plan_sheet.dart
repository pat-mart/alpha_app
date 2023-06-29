import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/util/enums/camera_types.dart';
import 'package:astro_planner/util/enums/catalog_types.dart';
import 'package:astro_planner/util/plan/plan_timespan.dart';
import 'package:astro_planner/util/setup/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/plan_m.dart';
import '../../models/target_m.dart';
import '../../util/plan/catalog_name.dart';
import '../../util/setup/telescope.dart';
import '../../viewmodels/plan_vm.dart';

class PlanSheet extends StatefulWidget {

  final VoidCallback onAddPlan;

  const PlanSheet({super.key, required this.onAddPlan});

  @override
  State<StatefulWidget> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container (
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        margin: const EdgeInsets.only(right: 14, left: 14),
        child: Column (
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: const EdgeInsets.only(left: 14, top: 14), // "negates" leftward margin
                  icon: const Icon(Icons.cancel_outlined, size: 36, color: Colors.grey),
                  onPressed: () => Navigator.pop(context))
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
            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Text('Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  SearchBar(hintText: 'Dummy text', constraints: BoxConstraints(maxWidth: 330), backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey))
                ],
              ),
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: CupertinoColors.activeBlue,
              textColor: CupertinoColors.white,
              onPressed: (){
                PlanViewModel planVm = PlanViewModel();
                planVm.addPlan(
                  Plan(
                    SkyObject('Orion nebula', CatalogName(CatalogTypes.messier, 41)),
                    SetupModel('Setup 2', Telescope('Celestron', 61, 360), Camera('Canon EOS 7D', 1.6, CameraTypes.dslr), true, true),
                    PlanTimespan(DateTime(2023, 6, 29, 20), const Duration(hours: 4, minutes: 30))
                  )
                );
                widget.onAddPlan();
                Navigator.pop(context);
              },
              child: const Text('Add to My Plans')
            )
          ],
        ),
      ),
    );
  }
}
