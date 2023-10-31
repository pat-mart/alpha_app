import 'package:astro_planner/viewmodels/create_plan/weather_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {

  late Future<bool> usingCelsius;

  @override
  void initState(){
    super.initState();

    usingCelsius = WeatherViewModel().usingCelsiusAsync;
  }

  @override
  Widget build(BuildContext context) {

    final weatherVm = Provider.of<WeatherViewModel>(context);

    return CupertinoFormSection.insetGrouped(
      header: const Text('TEMPERATURE'),
        children: [
          CupertinoFormRow(
            prefix: const Text('Use Celsius temperatures'),
              child: FutureBuilder(
                future: usingCelsius,
                builder: (context, snapshot) {
                  return CupertinoFormRow(
                    child: CupertinoSwitch(
                      value: weatherVm.usingCelsius,
                      onChanged: (newVal) async {
                        weatherVm.setUsingCelsius(newVal);
                      },
                    )
                  );
                },
              )
          )
        ]
    );
  }
}
