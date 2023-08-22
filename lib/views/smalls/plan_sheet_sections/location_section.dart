import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:flutter/cupertino.dart';

class LocationSection extends StatefulWidget {
  final TextEditingController latController, lonController;
  final CreatePlanViewModel createPlanVm;

  const LocationSection({
    super.key,
    required this.latController,
    required this.lonController,
    required this.createPlanVm
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  @override
  Widget build(BuildContext context) {
    final latController = widget.latController;
    final lonController = widget.lonController;

    final createPlanVm = widget.createPlanVm;

    return CupertinoFormSection.insetGrouped(
        margin: EdgeInsets.zero,
        header: const Text('LOCATION'),
        children: [
          CupertinoFormRow(
            prefix: const Text('Use this location'),
            child: CupertinoSwitch(
              onChanged: (newVal) async {

                createPlanVm.usingService = newVal;

                if(createPlanVm.isUsingService){
                  latController.clear();
                  lonController.clear();

                  await createPlanVm.location;
                }
              },
              activeColor: CupertinoColors.activeGreen,
              value: createPlanVm.isUsingService && createPlanVm.serviceEnabled,
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
            placeholder: (createPlanVm.isUsingService && createPlanVm.locationData != null) ? '${createPlanVm.locationData?.longitude?.toStringAsFixed(4) ?? 0.000}°'  : '0.000°...',
            enabled: !createPlanVm.isUsingService,

            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            autocorrect: false
        )
      ]
    );
  }
}
