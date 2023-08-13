import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/util/enums/camera_types.dart';
import 'package:astro_planner/util/enums/catalog_types.dart';
import 'package:astro_planner/util/plan/plan_timespan.dart';
import 'package:astro_planner/util/setup/camera.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:astro_planner/views/screens/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../models/plan_m.dart';
import '../../models/sky_obj_m.dart';
import '../../util/plan/catalog_name.dart';
import '../../util/setup/telescope.dart';
import '../../viewmodels/plan_vm.dart';

class PlanSheet extends StatefulWidget {

  const PlanSheet({super.key});

  @override
  State<StatefulWidget> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet> {

  final SearchViewModel _searchVm = SearchViewModel();

  late TextEditingController _searchController;

  bool _serviceEnabled = false;
  bool _usingService = true;

  late PermissionStatus _permissionStatus;

  double _lat = 0;
  double _lon = 0;

  final Location _location = Location();

  Future<void> getLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if(_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if(!_serviceEnabled) {
        _usingService = false;
        return;
      }
    }

    _permissionStatus = await _location.hasPermission();
    if(_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        _usingService = false;
        return;
      }
    }
  }

  @override
  void initState(){
    super.initState();
    _searchController = _searchVm.controller;
  }

  @override
  Widget build(BuildContext context) {

    return Column (
      children: <Widget> [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.only(left: 14, top: 14), // "negates" leftward margin
              child: const Icon(CupertinoIcons.xmark_circle, size: 36, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                Navigator.pop(context);
              }
            )
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Add new plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
            )
          ],
        ),

        const Padding(
          padding: EdgeInsets.only(top: 24, bottom: 8),
          child: Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white))
        ),

        Row(
          children: [
            const Text('Use current location'),
            FutureBuilder<void>(
              future: getLocation(),
              builder: (context, permission) => CupertinoSwitch(
                value: _usingService,
                onChanged: (newVal) => setState(() {
                  _usingService = newVal;
                  print(newVal);
                })
              ),
            )
          ],
        ),

        Row(
          children: [

          ],
        ),

        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Text('Target', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoColors.white)),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => const SearchScreen())
                    );
                    if(_searchVm.csvData.isEmpty){
                      await _searchVm.loadCsvData();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const CupertinoSearchTextField(
                    enabled: false,
                    padding: EdgeInsetsDirectional.fromSTEB(5.5, 10, 5.5, 10),
                    placeholder: 'Search for a target',
                  ),
                ),
              )
            ],
          ),
        ),
        CupertinoButton.filled(
            onPressed: () {
              PlanViewModel().addToList(
                Plan(
                  SkyObject('Orion nebula', CatalogName(CatalogTypes.messier, 41)),
                  Setup('Setup 2', Telescope('Celestron', 61, 360), Camera('Canon EOS 7D', 1.6, CameraTypes.dslr), true, true),
                  PlanTimespan(DateTime(2023, 7, 28, 21, 30), const Duration(minutes: 30)),
                  40.844,
                  -73.65
                )
              );
              Navigator.pop(context);
            },
            child: const Text('Add to plans', style: TextStyle(color: CupertinoColors.white))
        ),
      ],
    );
  }
}
