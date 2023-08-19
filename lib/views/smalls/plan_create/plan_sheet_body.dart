import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:astro_planner/views/screens/search_screen.dart';
import 'package:astro_planner/views/smalls/plan_create/datetime_section_v.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/search_vm.dart';


/// This class contains the target search and location sections of the 'create plan' sheet
/// I did not break those two sections into their own widgets for two reasons:
/// I (lazily) didn't want to migrate them into their own widgets, which leads into the next point:
/// I don't want to 'overcrowd' the sheet with many Provider instances
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

    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    CreatePlanViewModel createPlanVm = Provider.of<CreatePlanViewModel>(context);

    return CustomScrollView(
      anchor: 0.02,
      scrollBehavior: const CupertinoScrollBehavior(),
      slivers: <Widget>[
        const SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.only(top: 10)
          )
        ),
        CupertinoSliverNavigationBar(
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
        ),
        SliverToBoxAdapter(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
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
                          latController.clear();
                          lonController.clear();
                          if(newVal && createPlanVm.locationData == null){
                            await createPlanVm.getLocation();
                          }
                        },
                        activeColor: CupertinoColors.activeGreen,
                        value: createPlanVm.isUsingService,
                      )
                    ),
                  ),
                  CupertinoTextFormFieldRow(
                    key: const Key('Latitude'),
                    controller: latController,
                    onChanged: createPlanVm.onChangeLat,
                    validator: createPlanVm.latValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    prefix: Padding(
                      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/2.5),
                      child: const Text('Latitude   ')
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                    placeholder: (createPlanVm.isUsingService && createPlanVm.locationData != null) ? '${createPlanVm.locationData?.latitude?.toStringAsFixed(4) ?? 0.000}°' : '0.000°...',
                    enabled: !createPlanVm.isUsingService,

                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    autocorrect: false
                  ),
                  CupertinoTextFormFieldRow(
                    key: const Key('Longitude'),
                    controller: lonController,
                    onChanged: createPlanVm.onChangeLon,
                    validator: createPlanVm.lonValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    prefix: Padding(
                      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/2.5),
                      child: const Text('Longitude'),
                    ),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                    placeholder: (createPlanVm.isUsingService) ? '${createPlanVm.locationData?.longitude?.toStringAsFixed(4) ?? 0.000}°'  : '0.000°...',
                    enabled: !createPlanVm.isUsingService,

                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    autocorrect: false
                  )
                ]
              ),
              const DatetimeSection(),
              CupertinoFormSection.insetGrouped(
                margin: EdgeInsets.zero,
                header: const Text('TARGET'),
                children: [
                  CupertinoFormRow(
                    prefix: Row(
                      children: [
                        const Text('Use coordinate filtering'),
                        Material(
                          type: MaterialType.transparency,
                          child: IconButton(
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
                            icon: const Icon(CupertinoIcons.info_circle),
                          ),
                        )
                      ],
                    ),
                    child: CupertinoSwitch(
                      key: const Key('Filter switch'),
                      value: createPlanVm.isUsingFilter,
                      onChanged: (newVal) {
                        createPlanVm.usingFilter = newVal;
                        createPlanVm.showFilterWidgets(animationController);

                        if(!newVal){
                          createPlanVm.clearFilters();
                        }
                      },
                      activeColor: CupertinoColors.activeGreen
                    )
                  ),
                  AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return SizeTransition(
                          sizeFactor: animation,
                          child: Column (
                            children: [
                              CupertinoTextFormFieldRow(
                                key: const Key('Azimuth filter'),
                                validator: createPlanVm.azValidator,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                prefix: Padding(
                                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                                  child: const Text('Minimum azimuth'),
                                ),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(6))
                                ),
                                placeholder: '0.00°'
                              ),
                              CupertinoTextFormFieldRow(
                                key: const Key('Altitude filter'),
                                validator: createPlanVm.altValidator,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                prefix: Padding(
                                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                                  child: const Text('Minimum altitude '),
                                ),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(6))
                                ),
                                placeholder: '0.00°',
                              )
                            ]
                          ),
                        );
                      }
                  ),
                  CupertinoFormRow(
                    prefix: const Text('Target      '),
                    child: CupertinoSearchTextField(
                      enabled: true,
                      placeholder: 'Search for a target',
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => const SearchScreen())
                        );
                        await SearchViewModel().loadCsvData();
                      },
                    ),
                  ),
                ]
              ),
            ]
          )
        )
      ]
    );
  }
}
