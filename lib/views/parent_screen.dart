import 'package:astro_planner/viewmodels/plan_vm.dart';
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

  PlanViewModel planVm = PlanViewModel();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold (
      tabBar: CupertinoTabBar (
        activeColor: CupertinoColors.activeBlue,
        currentIndex:  _cIndex,
        onTap: (int index) => setState(() => _cIndex = index),
        backgroundColor: CupertinoColors.black,
        iconSize: 36,
        height: 52,
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
    );
  }
}

