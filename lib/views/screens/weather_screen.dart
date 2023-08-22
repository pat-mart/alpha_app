import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/plan_m.dart';

class WeatherScreen extends StatefulWidget {

  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    Plan? plan;

    CreatePlanViewModel createPlanVm = Provider.of<CreatePlanViewModel>(context);

    if(createPlanVm.lon != null && createPlanVm.lat != null && createPlanVm.getStartDateTime != null){
      plan = Plan.incomplete(createPlanVm.lat!, createPlanVm.lon!, createPlanVm.getStartDateTime);
    }
    return CupertinoPageScaffold (
      child: Column(
        children: [
          Text('Weather data', style: const CupertinoTextThemeData().navLargeTitleTextStyle),

        ],
      ),
    );
  }
}
