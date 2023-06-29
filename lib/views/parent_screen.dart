import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:astro_planner/views/screens/plans_screen.dart';
import 'package:astro_planner/views/screens/setups_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_octicons/flutter_octicons.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State createState() => ParentScreenState();
}

class ParentScreenState extends State<ParentScreen> {

  int _cIndex = 0;
  final List<Widget> _tabs = [
    const PlansScreen(),
    const SetupsScreen()
  ];

  PlanViewModel planVm = PlanViewModel();

  @override
  Widget build(BuildContext context) {
      return Scaffold (
          body: IndexedStack(
            index: _cIndex,
            children: _tabs,
          ),
          bottomNavigationBar: BottomNavigationBar (
            currentIndex:  _cIndex,
            onTap: (int index) => setState(() => _cIndex = index),
            backgroundColor: Colors.black26,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.white,
            iconSize: 32,
            items : const <BottomNavigationBarItem> [
              BottomNavigationBarItem(
                icon: Icon(Icons.list, color: Colors.white),
                label: 'Plans'
              ),
              BottomNavigationBarItem(
                icon: Icon(OctIcons.telescope_24, color: Colors.white),
                label: 'Setups',
              )
            ]
          ),
        );
  }
}

