import 'package:astro_planner/viewmodels/create_plan/weather_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

    return Column(
      children: [
        CupertinoFormSection.insetGrouped(
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
        ),
        CupertinoFormSection.insetGrouped(
          header: const Text('INFORMATION'),
          children: [
            CupertinoFormRow(
              prefix: const Text('View support page'),
              child: CupertinoButton(
                onPressed: () {launchUrl(Uri.parse('https://api.astro-alpha.com/support'));},
                child: const Icon(CupertinoIcons.chevron_forward),
              ),
            ),
            CupertinoFormRow(
              prefix: const Text('Privacy Policy'),
              child: CupertinoButton(
                onPressed: () {launchUrl(Uri.parse('https://api.astro-alpha.com/privacy-policy'));},
                child: const Icon(CupertinoIcons.chevron_forward),
              ),
            )
          ],
        )
      ],
    );
  }
}
