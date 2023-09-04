import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/views/smalls/plan_sheet_sections/weather_section.dart';
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

    DateTimeViewModel dateTimeVm = Provider.of<DateTimeViewModel>(context);

    return CupertinoFormSection.insetGrouped(
      margin: EdgeInsets.zero,
      header: const Text('DATE AND TIME'),
      children: [
        CupertinoFormRow(
          prefix: const Text('Start date & time'),
          helper: Text("Times are in device's current time zone (${DateTime.now().timeZoneName})", style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel.darkColor)),
          error: dateTimeVm.validStartDate ? null : const Text('The start date must be before the end'),
          child: CupertinoButton(
            borderRadius: BorderRadius.zero,
            onPressed: () {
              dateTimeVm.setNow();
              showCupertinoModalPopup(
                barrierColor: CupertinoColors.darkBackgroundGray,
                context: context,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height/3,
                  child: CupertinoDatePicker(
                    use24hFormat: true,
                    minimumDate: dateTimeVm.now,
                    maximumYear: dateTimeVm.now.year + 5,
                    initialDateTime: dateTimeVm.initialStartDate,
                    onDateTimeChanged: (DateTime value) {
                      dateTimeVm.startDateTime = value;
                    },
                  )
                )
              );
            },
            child: (dateTimeVm.getStartDateTime != null)
              ? Text(DateFormat('M.d.yyyy H:mm').format(dateTimeVm.getStartDateTime!))
              : const Text('Select start date')
          )
        ),
        CupertinoFormRow(
          prefix: const Text('End date & time'),
          child: CupertinoButton(
            borderRadius: BorderRadius.zero,
            onPressed: () {
              dateTimeVm.setNow();
              showCupertinoModalPopup(
                context: context,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height/3,
                  child: CupertinoPopupSurface(
                    child: CupertinoDatePicker(
                      use24hFormat: true,
                      maximumYear: 2033,
                      minimumDate: dateTimeVm.now,
                      initialDateTime: dateTimeVm.initialEndDate,
                      onDateTimeChanged: (DateTime value) {
                        dateTimeVm.endDateTime = value;
                      },
                    )
                  )
                )
              );
            },
            child: (dateTimeVm.getEndDateTime != null)
                ? Text(DateFormat('M.d.yyyy H:mm').format(dateTimeVm.getEndDateTime!))
                : const Text('Select end date')
          )
        )
      ]
    );
  }
}
