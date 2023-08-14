import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/util/enums/camera_types.dart';
import 'package:astro_planner/util/enums/catalog_types.dart';
import 'package:astro_planner/util/plan/plan_timespan.dart';
import 'package:astro_planner/util/setup/camera.dart';
import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:astro_planner/views/screens/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/plan_m.dart';
import '../../models/sky_obj_m.dart';
import '../../util/plan/catalog_name.dart';
import '../../util/setup/telescope.dart';
import '../../viewmodels/plan_vm.dart';

class PlanSheet extends StatefulWidget {

  const PlanSheet({super.key});

  @override
  State<StatefulWidget> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet> {

  final SearchViewModel _searchVm = SearchViewModel();

  late TextEditingController _searchController;

  @override
  void initState(){
    super.initState();
    _searchController = _searchVm.controller;
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<CreatePlanViewModel>(
      builder: (context, createPlanVm, _) => Column (
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

          CupertinoFormSection.insetGrouped(
            margin: EdgeInsets.zero,
            header: const Text('LOCATION'),
            children: [
              CupertinoFormRow(
                prefix: const Text('Use current location'),
                child: FutureBuilder<void>(
                  future: createPlanVm.getLocation(),
                  builder: (context, permission) => CupertinoSwitch(
                    onChanged: (newVal) {
                      createPlanVm.usingService = newVal;
                      createPlanVm.clearFields();
                    },
                    value: createPlanVm.isUsingService,
                  )
                ),
              ),
              CupertinoTextFormFieldRow(  // Latitude field (keyboardType does nothing)
                controller: createPlanVm.latController,
                onChanged: createPlanVm.onChangeLat,
                validator: createPlanVm.validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                prefix: Padding(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width/5,
                    child: const Text('Latitude')
                  ),
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                placeholder: (createPlanVm.isUsingService) ? '${createPlanVm.locationData!.latitude ?? 0.0000}' : '0.000...',
                enabled: !createPlanVm.isUsingService,
              ),
              CupertinoTextFormFieldRow(
                controller: createPlanVm.lonController,
                onChanged: createPlanVm.onChangeLon,
                validator: createPlanVm.validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                prefix: Padding(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width/5,
                    child: Text('Longitude')
                  ),
                ),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                placeholder: (createPlanVm.isUsingService) ? '${createPlanVm.locationData!.longitude ?? 0.0000}'  : '0.000...',
                enabled: !createPlanVm.isUsingService
              )
            ]
          ),

          Row(
            children: [

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
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => const SearchScreen())
                      );
                      if(_searchVm.csvData.isEmpty){
                        await _searchVm.loadCsvData();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const CupertinoSearchTextField(
                      enabled: false,
                      padding: EdgeInsetsDirectional.fromSTEB(5.5, 10, 5.5, 10),
                      placeholder: 'Search for a target',
                    ),
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
                    PlanTimespan(DateTime(2023, 7, 28, 21, 30), const Duration(minutes: 30)),
                    40.844,
                    -73.65
                  )
                );
                Navigator.pop(context);
              },
              child: const Text('Add to plans', style: TextStyle(color: CupertinoColors.white))
          ),
        ],
      ),
    );
  }
}
