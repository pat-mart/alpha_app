import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:astro_planner/viewmodels/weather_vm.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/weather_day.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../util/plan/date.dart';

class WeatherSection extends StatefulWidget {

  final CreatePlanViewModel createPlanVm;

  const WeatherSection({super.key, required this.createPlanVm});

  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection> {

  @override
  Widget build(BuildContext context) {

    var createPlanVm = widget.createPlanVm;

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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                clipBehavior: Clip.antiAlias,
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return Transform.scale(
                    scale: (!createPlanVm.isValidLocation) ? 1 : (index == weatherVm.selectedIndex ? 1.1 : 0.9),
                    child: CupertinoButton(
                      borderRadius: BorderRadius.zero,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 30, 0),
                      alignment: Alignment.centerLeft,
                      onPressed: (!createPlanVm.isValidLocation) ? null : () {
                        weatherVm.onChangeTime(index);
                      },
                      child: Text(
                        Date.previewOf(Date.forecastDays[index]),
                        style: TextStyle(fontWeight: index == weatherVm.selectedIndex && createPlanVm.isValidLocation ? FontWeight.bold : FontWeight.normal)
                      ),
                    ),
                  );
                }
              )
            ),
            Expanded(child: WeatherDay(weatherVm: weatherVm, createPlanVm: widget.createPlanVm))
          ],
        ),
      )
    );
  }
}
