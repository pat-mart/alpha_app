import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:flutter/cupertino.dart';

class LocationSection extends StatefulWidget {
  final CreatePlanViewModel createPlanVm;

  const LocationSection({super.key, required this.createPlanVm});

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> with WidgetsBindingObserver {

  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();

  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    latController.dispose();
    lonController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {

    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.resumed){
      await CreatePlanViewModel().checkHasPermission();

      if(!CreatePlanViewModel().serviceEnabled){
        CreatePlanViewModel().clearControllers([lonController, latController]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createPlanVm = widget.createPlanVm;

    return CupertinoFormSection.insetGrouped(
        margin: EdgeInsets.zero,
        header: const Text('LOCATION'),
        children: [
          CupertinoFormRow(
            prefix: Text('Use this location', style: TextStyle(color: createPlanVm.serviceEnabled ? CupertinoColors.white : CupertinoColors.inactiveGray.darkColor)),
            helper: !createPlanVm.serviceEnabled ? Text('Location permission denied', style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray.darkColor)) : null,
            child: CupertinoSwitch(
              onChanged: (newVal) async { // DO NOT TOUCH
                await createPlanVm.checkHasPermission();

                if(!createPlanVm.serviceEnabled){
                  createPlanVm.usingService = false;
                  return;
                }

                createPlanVm.usingService = newVal;

                if(newVal){
                  latController.clear();
                  lonController.clear();

                  await createPlanVm.location;
                }
              },
              activeColor: CupertinoColors.activeGreen,
              value: createPlanVm.isUsingService && createPlanVm.serviceEnabled,
            )
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
            placeholder: (createPlanVm.serviceEnabled && createPlanVm.isUsingService && createPlanVm.locationData != null) ? '${createPlanVm.locationData?.latitude?.toStringAsFixed(4) ?? 0.000}°' : '0.000°...',
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
            placeholder: (createPlanVm.serviceEnabled && createPlanVm.isUsingService && createPlanVm.locationData != null) ? '${createPlanVm.locationData?.longitude?.toStringAsFixed(4) ?? 0.000}°'  : '0.000°...',
            enabled: !createPlanVm.isUsingService,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            autocorrect: false
        )
      ]
    );
  }
}
