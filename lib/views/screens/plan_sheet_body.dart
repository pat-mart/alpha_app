import 'package:astro_planner/models/json_data/skyobj_data.dart';
import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/target_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/weather_vm.dart';
import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/datetime_section_v.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/location_section.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/plan_sheet_header.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/target_section.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/weather_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/plan_m.dart';

class PlanSheet extends StatefulWidget {
  final Plan? planToLoad;

  const PlanSheet({super.key, this.planToLoad});

  @override
  State<StatefulWidget> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController animationController;
  late Animation<double> animation;

  late bool isEdit;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    isEdit = widget.planToLoad != null;

    if (isEdit) {
      final locationVm = LocationViewModel();
      final targetVm = TargetViewModel();
      final dateTimeVm = DateTimeViewModel();

      locationVm.onChangeLat(widget.planToLoad!.latitude.toString(), false);
      locationVm.onChangeLon(widget.planToLoad!.longitude.toString(), false);

      targetVm.onChangeAzMin(widget.planToLoad!.azMin.toString(), false);
      targetVm.onChangeAzMax(widget.planToLoad!.azMax.toString(), false);
      targetVm.onChangeAltFilter(
          widget.planToLoad!.altThresh.toString(), false);

      bool usingFilter = widget.planToLoad!.azMin > 0 ||
          widget.planToLoad!.azMax > 0 ||
          widget.planToLoad!.altThresh > 0;

      targetVm.usingFilter(usingFilter, false);

      dateTimeVm.setStartDateTime(
          widget.planToLoad!.timespan.dateTimeRange.start, false);
      dateTimeVm.setEndDateTime(
          widget.planToLoad!.timespan.dateTimeRange.end, false);

      SearchViewModel().selectedResult = widget.planToLoad!.target;
    } else {
      SearchViewModel().selectedResult = null;
      SearchViewModel().previewedResult = null;

      TargetViewModel().altFilter = null;
      TargetViewModel().azMax = null;
      TargetViewModel().azMin = null;
      TargetViewModel().usingFilter(false, false);

      LocationViewModel().usingService(false, false);
    }
  }

  @override
  void dispose() {
    LocationViewModel().lon = null;
    LocationViewModel().lat = null;

    DateTimeViewModel().startDateTime = null;
    DateTimeViewModel().endDateTime = null;

    SearchViewModel().selectedResult = null;
    SearchViewModel().previewedResult = null;

    TargetViewModel().altFilter = null;
    TargetViewModel().azMax = null;
    TargetViewModel().azMin = null;

    TargetViewModel().usingFilter(false, false);
    LocationViewModel().usingService(false, false);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationVm = Provider.of<LocationViewModel>(context);
    final targetVm = Provider.of<TargetViewModel>(context);
    final dateTimeVm = Provider.of<DateTimeViewModel>(context);

    final weatherVm = Provider.of<WeatherViewModel>(context);
    final planVm = Provider.of<PlanViewModel>(context);
    final searchVm = Provider.of<SearchViewModel>(context);

    return CustomScrollView(
        scrollBehavior: const CupertinoScrollBehavior(),
        slivers: <Widget>[
          const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.only(top: 10))),
          PlanSheetHeader(isEdit: isEdit),
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
                      WeatherSection(
                          locationVm: locationVm, weatherVm: weatherVm)
                    ]),
                const DatetimeSection(),
                TargetSection(
                    targetVm: targetVm,
                    animationController: animationController,
                    animation: animation,
                    isEdit: isEdit),
                Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 5,
                      right: MediaQuery.of(context).size.width / 5),
                  padding: const EdgeInsets.only(top: 20, bottom: 8),
                  child: CupertinoButton.filled(
                      onPressed: (!targetVm.isValidFilter ||
                              !dateTimeVm.validDates ||
                              !locationVm.isValidLocation ||
                              searchVm.selectedResult == null)
                          ? null
                          : () {
                              SkyObjectData? objData;
                              if (SearchViewModel().infoCache[SearchViewModel()
                                      .selectedResult
                                      ?.catalogName] !=
                                  null) {
                                objData = SearchViewModel().infoCache[
                                    SearchViewModel()
                                        .selectedResult
                                        ?.catalogName];
                              }
                              final newPlan = Plan(
                                  SearchViewModel().selectedResult!,
                                  dateTimeVm.startDateTime ?? DateTime.now(),
                                  dateTimeVm.endDateTime ?? DateTime.now(),
                                  locationVm.lat!,
                                  locationVm.lon!,
                                  dateTimeVm.now.timeZoneName,
                                  objData,
                                  false,
                                  targetVm.azMax ?? -1,
                                  targetVm.azMin ?? -1,
                                  targetVm.altFilter ?? -1);
                              if (widget.planToLoad == null) {
                                planVm.add(newPlan);
                              } else {
                                planVm.update(widget.planToLoad!, newPlan);
                              }
                              Navigator.pop(context);
                            },
                      child: Text(
                          widget.planToLoad == null ? 'Add plan' : 'Save',
                          style:
                              const TextStyle(color: CupertinoColors.white))),
                )
              ]))
        ]);
  }
}
