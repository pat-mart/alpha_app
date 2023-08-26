import 'dart:ui';

import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/weather_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DatetimeSection extends StatefulWidget {
  const DatetimeSection({super.key});

  @override
  State<DatetimeSection> createState() => _DatetimeSectionState();
}

class _DatetimeSectionState extends State<DatetimeSection> {

  @override
  Widget build(BuildContext context) {

    CreatePlanViewModel createPlanVm = Provider.of<CreatePlanViewModel>(context);

    return CupertinoFormSection.insetGrouped(
      margin: EdgeInsets.zero,
      header: const Text('WEATHER, DATE AND TIME'),
      children: [
        const WeatherSection(),
        CupertinoFormRow(
          prefix: const Text('Start date & time'),
          error: (createPlanVm.validStartDate) ? null : const Text('Please make sure the start date is before the end'),
          child: CupertinoButton(
            borderRadius: BorderRadius.zero,
            onPressed: () {
              createPlanVm.setNow();
              showCupertinoModalPopup(
                barrierColor: CupertinoColors.darkBackgroundGray,
                context: context,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height/3,
                  child: CupertinoDatePicker(
                    use24hFormat: true,
                    minimumDate: createPlanVm.now,
                    maximumYear: 2033,
                    initialDateTime: createPlanVm.getStartDateTime ?? createPlanVm.now,
                    onDateTimeChanged: (DateTime value) {
                      createPlanVm.startDateTime = value;
                    },
                  )
                )
              );
            },
            child: Text(DateFormat('M.d.yyyy H:mm').format(createPlanVm.getStartDateTime ?? createPlanVm.now)) //Change
          )
        ),
        CupertinoFormRow(
          prefix: const Text('End date & time'),
          child: CupertinoButton(
            borderRadius: BorderRadius.zero,
            onPressed: () {
              createPlanVm.setNow();
              showCupertinoModalPopup(
                context: context,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height/3,
                  child: CupertinoPopupSurface(
                    child: CupertinoDatePicker(
                      use24hFormat: true,
                      maximumYear: 2033,
                      minimumDate: createPlanVm.getStartDateTime ?? createPlanVm.now,
                      initialDateTime: createPlanVm.getEndDateTime ?? createPlanVm.now.add(const Duration(minutes: 1)),
                      onDateTimeChanged: (DateTime value) {
                        createPlanVm.endDateTime = value;
                      },
                    )
                  )
                )
              );
            },
            child: Text(DateFormat('M.d.yyyy H:mm').format(createPlanVm.getEndDateTime ?? DateTime.now().add(const Duration(minutes: 1))))
          )
        )
      ]
    );
  }
}
