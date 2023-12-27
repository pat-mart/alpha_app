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

class ParentScreenState extends State<ParentScreen> { // Like main but stateful

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
                iconSize: 40,
                height: 65,
                items : const <BottomNavigationBarItem> [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.list_bullet_below_rectangle, color: CupertinoColors.systemGrey5),
                    activeIcon: Icon(CupertinoIcons.list_bullet_below_rectangle, color: CupertinoColors.activeBlue),
                    label: 'Plans'
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings, color: CupertinoColors.systemGrey5),
                    activeIcon: Icon(CupertinoIcons.settings, color: CupertinoColors.activeBlue),
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

