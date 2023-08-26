import 'package:astro_planner/viewmodels/weather_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class WeatherSection extends StatefulWidget {
  const WeatherSection({super.key});

  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection> {

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 10.0),
      height: MediaQuery.of(context).size.height / 6,
      child: Consumer<WeatherViewModel>(
        builder: (context, weatherVm, _) => Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weather forecast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Image.asset(
                  './assets/combined-mark-dark.png',
                  scale: 5.5
                )
              ]
            ),
            CupertinoButton(
              onPressed: () {
                showCupertinoModalPopup(context: context, builder: (context) =>
                  SizedBox(
                    height: MediaQuery.of(context).size.height/3,
                  )
                );
              },
              alignment: Alignment.centerLeft,
              borderRadius: BorderRadius.zero,
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Text(weatherVm.getFormattedDate(), style: const TextStyle(color: CupertinoColors.activeBlue)),
                  const Icon(CupertinoIcons.chevron_up_chevron_down, size: 20)
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
