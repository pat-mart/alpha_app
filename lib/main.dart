import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/target_vm.dart';
import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/weather_vm.dart';
import 'package:astro_planner/views/parent_screen.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main () {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => PlanViewModel()),
        ChangeNotifierProvider(create: (_) => DateTimeViewModel()),
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()),
        ChangeNotifierProvider(create: (_) => TargetViewModel())
      ],
      child: const CupertinoApp (
        theme: CupertinoThemeData(brightness: Brightness.dark, applyThemeToAll: true),
        home: Scaffold (
          body: ParentScreen()
        )
      ),
    );
  }
}
