import 'package:astro_planner/util/plan/plan_timespan.dart';
import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/target_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/weather_vm.dart';
import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/datetime_section_v.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/plan_sheet_header.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/target_section.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/weather_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:astro_planner/views/smalls/plan_sheet_sections/location_section.dart';

import '../../models/plan_m.dart';
import '../../models/sky_obj_m.dart';

class PlanSheet extends StatefulWidget {

  const PlanSheet({super.key});

  @override
  State<StatefulWidget> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet> with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState(){
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {

    LocationViewModel locationVm = Provider.of<LocationViewModel>(context);
    TargetViewModel targetVm = Provider.of<TargetViewModel>(context);
    WeatherViewModel weatherVm = Provider.of<WeatherViewModel>(context);

    return CustomScrollView(
      scrollBehavior: const CupertinoScrollBehavior(),
      slivers: <Widget>[
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 10)
          )
        ),
        const PlanSheetHeader(),
        SliverToBoxAdapter(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              LocationSection(locationVm: locationVm, weatherVm: weatherVm),
              CupertinoFormSection.insetGrouped(
                header: const Text('WEATHER'),
                margin: EdgeInsets.zero,
                children: [
                  WeatherSection(locationVm: locationVm, weatherVm: weatherVm)
                ]
              ),
              const DatetimeSection(),
              TargetSection(targetVm: targetVm, animationController: animationController, animation: animation),
              Container(
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/5, right: MediaQuery.of(context).size.width/5),
                padding: const EdgeInsets.only(top: 20),
                child: Consumer<DateTimeViewModel>(
                  builder: (context, dateTimeVm, _) => CupertinoButton.filled(
                    onPressed: (!dateTimeVm.validStartDate  || !locationVm.isValidLocation || SearchViewModel().selectedResult == null) ? null : () {
                      PlanViewModel().add(
                        Plan(
                          SkyObject.fromCsvRow(SearchViewModel().selectedResult!),
                          dateTimeVm.getStartDateTime!,
                          dateTimeVm.getEndDateTime!,
                          locationVm.lat!,
                          locationVm.lon!,
                          dateTimeVm.now.timeZoneName,
                          null
                        )
                      );

                      Navigator.pop(context);
                    },
                    child: const Text('Add plan', style: TextStyle(color: CupertinoColors.white))
                  ),
                )
              )
            ]
          )
        )
      ]
    );
  }
}
