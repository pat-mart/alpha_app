import 'package:astro_planner/views/parent_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main () {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp (
      theme: ThemeData(scaffoldBackgroundColor: Colors.black12),
      home: const Scaffold (
        body: ParentScreen()
      )
    );
  }
}
