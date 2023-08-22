import 'dart:ui';

import 'package:astro_planner/viewmodels/create_plan_vm.dart';
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
        CupertinoFormRow(
          prefix: CupertinoButton(
            borderRadius: BorderRadius.zero,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            child: const Text('View 10-day weather data'),
            onPressed: () {

            },
          ),
          child: Container()
        ),
        CupertinoFormRow(
          prefix: const Text('Start date & time'),
          child: CupertinoButton(
            borderRadius: BorderRadius.zero,
            onPressed: () {
              showCupertinoModalPopup(
                  barrierColor: const Color(0xBB000000),
                  context: context,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height/3,
                    child: CupertinoPopupSurface(
                      child: CupertinoDatePicker(
                        use24hFormat: true,
                        minimumDate: DateTime.now(),
                        onDateTimeChanged: (DateTime value) {
                          createPlanVm.startDateTime = value;
                        },
                      ),
                    )
                  )
              );
            },
            child: Text(DateFormat('M.d.yyyy HH:MM').format(createPlanVm.getStartDateTime ?? DateTime.now())) //Change
          )
        ),
        CupertinoFormRow(
          prefix: const Text('End date & time'),
          child: CupertinoButton(
            borderRadius: BorderRadius.zero,
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height/3,
                    child: CupertinoPopupSurface(
                      child: CupertinoDatePicker(
                        use24hFormat: true,
                        onDateTimeChanged: (DateTime value) {
                          createPlanVm.endDateTime = value;
                        },
                      ),
                    )
                )
              );
            },
            child: Text(DateFormat('M.d.yyyy HH:MM').format(createPlanVm.getEndDateTime ?? DateTime.now().add(const Duration(minutes: 1))))
          )
        )
      ]
    );
  }
}
