import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../models/json_data/weather_data.dart';
import '../../models/plan_m.dart';

class PlanCard extends StatefulWidget {

  final int index;

  const PlanCard({super.key, required this.index});

  @override
  State<StatefulWidget> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {

  late Future<WeatherData?> weatherFuture;

  final DateFormat dayFormat = DateFormat('E, M/d');
  final DateFormat timeFormat = DateFormat('H:mm');

  @override
  void initState() {
    super.initState();
    Plan plan = PlanViewModel().getPlan(widget.index);

    weatherFuture = plan.getWeatherData(RequestType.planDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Consumer<PlanViewModel>(
        builder: (context, planVm, _) {
          Plan plan = planVm.getPlan(widget.index);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( //Date in EE, MM, d
                plan.timespan.numDays > 1 ? plan.timespan.formattedRange : dayFormat.format(plan.timespan.startDateTime),
                style: const TextStyle(color: CupertinoColors.white, fontSize: 20, fontWeight: FontWeight.bold)
              ),
              Text(
                '${timeFormat.format(plan.timespan.startDateTime)} (${plan.timezone}) to ${timeFormat.format(plan.timespan.dateTimeRange.end)}',
                style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor, fontSize: 16)
              ),
              const Padding(padding: EdgeInsets.only(bottom: 8)),
              Card(
                color: CupertinoColors.systemFill.darkColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: SizedBox (
                  width: double.infinity,
                  height: (MediaQuery.of(context).orientation == Orientation.portrait) ? MediaQuery.of(context).size.height/6 : MediaQuery.of(context).size.height/2.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 8, bottom: 12),
                            child: Text(plan.target.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          PullDownButton(
                            itemBuilder: (context) => [
                              PullDownMenuItem(
                                onTap: () {},
                                title: 'Edit',
                                icon: CupertinoIcons.pencil
                              ),
                              PullDownMenuItem(
                                onTap: () {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (context) => CupertinoAlertDialog(
                                        title: Text('Delete plan ${plan.target.catName}?'),
                                        content: const Text('This action cannot be undone.'),
                                        actions: [
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: const Text('Cancel'),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          CupertinoDialogAction(
                                            isDestructiveAction: true,
                                            child: const Text('Delete'),
                                            onPressed: () {
                                              planVm.delete(plan.uuid!);
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      )
                                  );
                                },
                                title: 'Delete',
                                isDestructive: true,
                                icon: CupertinoIcons.delete,
                              )
                            ],
                            buttonBuilder: (context, showMenu) => CupertinoButton(onPressed: showMenu, child: const Icon(CupertinoIcons.pencil_ellipsis_rectangle))
                          )
                        ]
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: FutureBuilder(
                          future: weatherFuture,
                          builder: (context, snapshot) {
                            if(snapshot.data != null && !snapshot.hasError){
                              return const Text('Data');
                            }
                            return const Text('No Data');
                          }
                        )
                      ),
                    ],
                  )
                )
              ),
              const Padding(padding: EdgeInsets.only(bottom: 18))
            ],
          );
        } // Consumer function body,
      ),
    );
  }
}
