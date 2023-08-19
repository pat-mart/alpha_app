import 'dart:ui';

import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:flutter/cupertino.dart';
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
            child: const Text('View 3-day weather data'),
            onPressed: () {

            },
          ),
          child: Container()
        ),
        CupertinoFormRow(
          prefix: const Text('Start date'),
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
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (DateTime value) {
                          createPlanVm.startDate = value;
                        },
                      ),
                    )
                  )
              );
            },
            child: Text(DateFormat('M.d.yyyy').format(createPlanVm.getStartDate ?? DateTime.now())) //Change
          )
        ),
        CupertinoFormRow(
          prefix: const Text('Start time'),
          child: CupertinoButton(
            borderRadius: BorderRadius.zero,
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height/3,
                    child: CupertinoPopupSurface(
                      child: CupertinoDatePicker(
                        minimumDate: DateTime.now(),
                        use24hFormat: true,
                        mode: CupertinoDatePickerMode.time,
                        onDateTimeChanged: (DateTime value) {
                          createPlanVm.startDate = value;
                        },
                      ),
                    )
                )
              );
            },
            child: Text('')
          )
        )
      ]
    );
  }
}
