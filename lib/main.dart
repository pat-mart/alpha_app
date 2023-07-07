import 'package:astro_planner/views/parent_screen.dart';
import 'package:flutter/cupertino.dart';

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
    return CupertinoApp (
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: Container(
        margin: const EdgeInsets.only(left: 14, right: 14),
        child: const Scaffold (
          body: ParentScreen()
        ),
      )
    );
  }
}
