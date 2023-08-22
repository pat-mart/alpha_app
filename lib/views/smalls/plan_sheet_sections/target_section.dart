import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../viewmodels/search_vm.dart';
import '../../screens/search_screen.dart';

class TargetSection extends StatefulWidget {
  final CreatePlanViewModel createPlanVm;
  final AnimationController animationController;
  final Animation<double> animation;

  const TargetSection({super.key, required this.createPlanVm, required this.animationController, required this.animation});

  @override
  State<TargetSection> createState() => _TargetSectionState();
}

class _TargetSectionState extends State<TargetSection> {
  @override
  Widget build(BuildContext context) {
    final createPlanVm = widget.createPlanVm;

    final animationController = widget.animationController;
    final animation = widget.animation;

    return CupertinoFormSection.insetGrouped(
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
                          onChanged: createPlanVm.onChangeAzFilter,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          prefix: Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                            child: const Text('Minimum azimuth'),
                          ),
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6))
                          ),
                          placeholder: '0.00°',
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          autocorrect: false,
                        ),
                        CupertinoTextFormFieldRow(
                            key: const Key('Altitude filter'),
                            validator: createPlanVm.altValidator,
                            onChanged: createPlanVm.onChangeLat,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            prefix: Padding(
                              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                              child: const Text('Minimum altitude '),
                            ),
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(6))
                            ),
                            placeholder: '0.00°',
                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            autocorrect: false
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
    );
  }
}
