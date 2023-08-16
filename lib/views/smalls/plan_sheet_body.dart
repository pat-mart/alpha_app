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

// TODO consider breaking this up into more manageable pieces

class PlanSheet extends StatefulWidget {

  const PlanSheet({super.key});

  @override
  State<StatefulWidget> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet> {

  final SearchViewModel _searchVm = SearchViewModel();

  late TextEditingController _searchController;

  @override
  void initState() {
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
                    onChanged: (newVal) async {
                      createPlanVm.usingService = newVal;
                      await createPlanVm.getLocation();
                    },
                    value: createPlanVm.isUsingService,
                  )
                ),
              ),
              CupertinoTextFormFieldRow(   // Latitude field (keyboardType does nothing)
                controller: createPlanVm.latController,
                onChanged: createPlanVm.onChangeLat,
                validator: createPlanVm.validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                prefix: Padding(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/2.5),
                  child: const Text('Latitude   ')
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                placeholder: (createPlanVm.isUsingService && createPlanVm.locationData != null) ? '${createPlanVm.locationData?.latitude?.toStringAsFixed(3) ?? 0.000}' : '0.00°...',
                enabled: !createPlanVm.isUsingService,
              ),
              CupertinoTextFormFieldRow(
                controller: createPlanVm.lonController,
                onChanged: createPlanVm.onChangeLon,
                validator: createPlanVm.validator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                prefix: Padding(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/2.5),
                  child: const Text('Longitude'),
                ),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                placeholder: (createPlanVm.isUsingService) ? '${createPlanVm.locationData?.longitude?.toStringAsFixed(3) ?? 0.000}'  : '0.00°...',
                enabled: !createPlanVm.isUsingService
              )
            ]
          ),

          CupertinoFormSection.insetGrouped(
            margin: EdgeInsets.zero,
            header: const Text('TARGET'),
            children: [
              CupertinoFormRow(
                prefix: Row(
                  children: [
                    const Text('Use coordinate filtering'),
                    CupertinoButton(
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (buildContext) =>
                             CupertinoAlertDialog(
                              title: const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text('About coordinate filtering'),
                              ),
                              content: const Text('Alpha can indicate what times a target is above a minimum altitude or azimuth'),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  onPressed: () => Navigator.pop(buildContext),
                                  child: const Text('OK')
                                )
                              ],
                            )
                        );
                      },
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.info_circle),
                    )
                  ],
                ),
                child: CupertinoSwitch(
                  value: createPlanVm.isUsingFilter,
                  onChanged: (newVal) => createPlanVm.usingFilter = newVal
                )
              ),
              if(createPlanVm.isUsingFilter) ... [
                CupertinoTextFormFieldRow(
                  validator: createPlanVm.validator,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  prefix: Padding(
                    padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                    child: const Text('Minimum longitude'),
                  ),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6))
                  ),
                  placeholder: '0.00°'
                ),
                CupertinoTextFormFieldRow(
                  validator: createPlanVm.validator,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  prefix: Padding(
                    padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                    child: const Text('Minimum latitude   '),
                  ),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6))
                  ),
                  placeholder: '0.00°',
                )
              ],
              CupertinoFormRow(
                prefix: const Text('Target      '),
                child: CupertinoSearchTextField(
                  onTap: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => const SearchScreen())
                    );
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  placeholder: 'Search for a target',
                ),
              ),
            ]
          ),
          CupertinoButton.filled(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Add to plans', style: TextStyle(color: CupertinoColors.white))
          ),
        ],
      ),
    );
  }
}
