import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:astro_planner/viewmodels/theme_vm.dart';
import 'package:astro_planner/views/screens/plans_screen.dart';
import 'package:astro_planner/views/screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State createState() => ParentScreenState();
}

class ParentScreenState extends State<ParentScreen> {

  int _cIndex = 0;
  final List<Widget> _tabs = [
    const PlansScreen(),
    const SettingsScreen()
  ];

  late Future<bool> isRed;

  @override
  void initState(){
    super.initState();

    isRed = ThemeViewModel().isRed;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: isRed,
      builder: (context, snapshot) {

        bool redIsUsable = false;

        if(snapshot.hasData && snapshot.data != null){
          redIsUsable = snapshot.data!;
        }

        return Container(
          color: Colors.red.withOpacity(0.5),
          child: CupertinoTheme(
            data: CupertinoThemeData(brightness: Brightness.dark, primaryColor: redIsUsable ? CupertinoColors.systemRed : null),
            child: CupertinoTabScaffold (
              tabBar: CupertinoTabBar (
                activeColor: CupertinoColors.activeBlue,
                currentIndex:  _cIndex,
                onTap: (int index) => setState(() => _cIndex = index),
                backgroundColor: CupertinoColors.black,
                iconSize: 40,
                height: 60,
                items : const <BottomNavigationBarItem> [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.list_bullet, color: Colors.white),
                    label: 'My plans'
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings, color: Colors.white),
                    label: 'Settings',
                  )
                ]
              ),
              tabBuilder: (context, index){
                return CupertinoTabView(
                  builder: (context) => _tabs[index]
                );
              }
            ),
          ),
        );
      }
    );
  }
}

