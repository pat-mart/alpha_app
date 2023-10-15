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

class PlanSheet extends StatefulWidget {

  final Plan? planToLoad;

  const PlanSheet({super.key, this.planToLoad});

  @override
  State<StatefulWidget> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet> with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late AnimationController animationController;
  late Animation<double> animation;

  late bool isEdit;

  @override
  void initState(){
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    isEdit = widget.planToLoad != null;

    if(isEdit){

      final locationVm = LocationViewModel();
      final targetVm = TargetViewModel();
      final dateTimeVm = DateTimeViewModel();

      locationVm.onChangeLat(widget.planToLoad!.latitude.toString(), false);
      locationVm.onChangeLon(widget.planToLoad!.longitude.toString(), false);

      targetVm.onChangeAzMin(widget.planToLoad!.azMin.toString(), false);
      targetVm.onChangeAzMax(widget.planToLoad!.azMax.toString(), false);
      targetVm.onChangeAltFilter(widget.planToLoad!.altThresh.toString(), false);

      dateTimeVm.setStartDateTime(widget.planToLoad!.timespan.dateTimeRange.start, false);
      dateTimeVm.setEndDateTime(widget.planToLoad!.timespan.dateTimeRange.end, false);

      SearchViewModel().selectedResult = widget.planToLoad!.target;
    }
  }

  @override
  void dispose(){

    LocationViewModel().lon = null;
    LocationViewModel().lat = null;

    DateTimeViewModel().startDateTime = null;
    DateTimeViewModel().endDateTime = null;

    TargetViewModel().altFilter = null;
    TargetViewModel().azMax = null;
    TargetViewModel().azMin = null;
    TargetViewModel().usingFilter(false, false);

    super.dispose();
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
              TargetSection(targetVm: targetVm, animationController: animationController, animation: animation, isEdit: isEdit),
              Container(
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/5, right: MediaQuery.of(context).size.width/5),
                padding: const EdgeInsets.only(top: 20),
                child: Consumer<DateTimeViewModel>(
                  builder: (context, dateTimeVm, _) => CupertinoButton.filled(
                    onPressed: (!dateTimeVm.validStartDate  || !locationVm.isValidLocation || SearchViewModel().selectedResult == null) ? null : () {
                      PlanViewModel().add(
                        Plan(
                          SearchViewModel().selectedResult!,
                          dateTimeVm.startDateTime!,
                          dateTimeVm.endDateTime!,
                          locationVm.lat!,
                          locationVm.lon!,
                          dateTimeVm.now.timeZoneName,
                          null
                        )
                      );
                      Navigator.pop(context);
                    },
                    child: Text(widget.planToLoad == null ? 'Add plan' : 'Save changes', style: const TextStyle(color: CupertinoColors.white))
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
