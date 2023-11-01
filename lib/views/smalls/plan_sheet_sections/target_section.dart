import 'package:astro_planner/viewmodels/create_plan/target_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/search_vm.dart';
import '../../screens/search_screen.dart';

class TargetSection extends StatefulWidget {

  final AnimationController animationController;
  final Animation<double> animation;

  final TargetViewModel targetVm;

  final bool isEdit;

  const TargetSection({super.key, required this.animationController, required this.animation, required this.targetVm,  required this.isEdit});

  @override
  State<TargetSection> createState() => _TargetSectionState();
}

class _TargetSectionState extends State<TargetSection> {

  final TextEditingController azMinController = TextEditingController();
  final TextEditingController azMaxController = TextEditingController();
  final TextEditingController altThreshController = TextEditingController();


  @override
  void initState() {
    super.initState();

    final targetVm = TargetViewModel();

    bool validFilter(double? value){
      return (value ??= -1) > 0;
    }

    if(widget.isEdit){
      if(validFilter(targetVm.altFilter) || validFilter(targetVm.azMax) || validFilter(targetVm.azMin)){
        widget.animationController.value = widget.animationController.upperBound;

        altThreshController.text = targetVm.altFilter != -1 ? targetVm.altFilter.toString() : '';
        azMaxController.text = targetVm.azMax != -1 ? targetVm.azMax.toString() : '';
        azMinController.text = targetVm.azMin != -1 ? targetVm.azMin.toString() : '';

        targetVm.usingFilter(true, false);
      }
      else {
        targetVm.usingFilter(false, false);
      }
    }
  }

  @override
  void dispose() {

    azMinController.dispose();
    azMaxController.dispose();
    altThreshController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationController = widget.animationController;
    final animation = widget.animation;
    final targetVm = widget.targetVm;

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
                              content: const Text('Alpha can indicate what times a target is above a minimum altitude, or within a certain azimuth range.'),
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
                  value: targetVm.isUsingFilter,
                  onChanged: (newVal) {
                    targetVm.usingFilter(newVal);
                    targetVm.showFilterWidgets(animationController);

                    if(!newVal){
                      targetVm.clearFilters();
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
                          key: const Key('Azimuth minimum'),
                          controller: azMinController,
                          validator: targetVm.azMinValidator,
                          onChanged: targetVm.onChangeAzMin,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          prefix: Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                            child: const Text('Minimum azimuth '),
                          ),
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6))
                          ),
                          placeholder: '0.00°',
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          autocorrect: false,
                        ),
                        CupertinoTextFormFieldRow(
                          key: const Key('Azimuth maximum'),
                          validator: targetVm.azMaxValidator,
                          controller: azMaxController,
                          onChanged: targetVm.onChangeAzMax,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          prefix: Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                            child: const Text('Maximum azimuth'),
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
                          controller: altThreshController,
                          validator: targetVm.altValidator,
                          onChanged: targetVm.onChangeAltFilter,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          prefix: Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width/3),
                            child: const Text('Minimum altitude  '),
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
          Consumer<SearchViewModel>(
            builder: (context, searchVm, _) =>  CupertinoFormRow(
              prefix: const Text('Target      '),
              child: (searchVm.selectedResult == null) ? (CupertinoSearchTextField(
                enabled: true,
                placeholder: 'Search for a target',
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => SearchScreen(initialQueryValue: '', isEdit: widget.isEdit))
                  );
                  await searchVm.loadCsvData();
                },
              )
            ): CupertinoButton(
                onPressed: () async {

                  await searchVm.loadCsvData();

                  searchVm.previewedResult = searchVm.selectedResult;

                  String toLoad;
                  final result = searchVm.selectedResult;

                  if(result!.properName == ''){
                    toLoad = result.catalogName;
                  }
                  else {
                    toLoad = searchVm.removeProperAlias(result.properName);
                  }

                  searchVm.loadSearchResults(toLoad);

                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => SearchScreen(initialQueryValue: toLoad, isEdit: widget.isEdit))
                  );
                },
                child: Text(
                  (searchVm.selectedResult!.properName == '')
                      ? searchVm.selectedResult!.catalogName
                      : searchVm.removeProperAlias(searchVm.selectedResult!.properName)
                ),
              )
          ),
        )
      ]
    );
  }
}
