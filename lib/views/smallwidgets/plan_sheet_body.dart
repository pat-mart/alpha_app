import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/util/enums/camera_types.dart';
import 'package:astro_planner/util/enums/catalog_types.dart';
import 'package:astro_planner/util/plan/plan_timespan.dart';
import 'package:astro_planner/util/setup/camera.dart';
import 'package:astro_planner/viewmodels/target_search_vm.dart';
import 'package:astro_planner/views/screens/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/plan_m.dart';
import '../../models/sky_obj_m.dart';
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

  final TargetSearchViewModel _searchVm = TargetSearchViewModel();
  late FocusNode _focusNode;
  late TextEditingController _searchController;

  void _unfocusSearch() {
    if(_focusNode.hasFocus){
      _focusNode.unfocus();
    }
  }

  @override
  void initState(){
    super.initState();
    _focusNode = FocusNode();
    _searchController = _searchVm.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column (
      children: <Widget> [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.only(left: 14, top: 14), // "negates" leftward margin
              child: const Icon(CupertinoIcons.xmark_circle, size: 36, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                Navigator.pop(context);
              }
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
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Text('Target', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoColors.white)),
              ),
              Expanded(
                child: CupertinoSearchTextField(
                  enabled: false,
                  padding: const EdgeInsetsDirectional.fromSTEB(5.5, 10, 5.5, 10),
                  placeholder: 'Search for a target',
                  onTap: () {
                    _unfocusSearch();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => const SearchScreen())
                    );
                  },
                ),
              )
            ],
          ),
        ),
        CupertinoButton.filled(
            onPressed: () {
              PlanViewModel().addToList(
                Plan(
                  SkyObject('Orion nebula', CatalogName(CatalogTypes.messier, 41)),
                  Setup('Setup 2', Telescope('Celestron', 61, 360), Camera('Canon EOS 7D', 1.6, CameraTypes.dslr), true, true),
                  PlanTimespan(DateTime(2023, 7, 8, 21, 30), const Duration(hours: 6, minutes: 30)),
                  40.03,
                  -73.10
                )
              );
              widget.onAddPlan(); //Triggers callback
              Navigator.pop(context);
            },
            child: const Text('Add to plans', style: TextStyle(color: CupertinoColors.white))
        ),
      ],
    );
  }
}
