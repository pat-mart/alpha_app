import 'package:astro_planner/util/enums/camera_types.dart';
import 'package:astro_planner/views/smallwidgets/setup_v.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/setup_m.dart';
import '../../util/setup/camera.dart';
import '../../util/setup/telescope.dart';
import '../../viewmodels/setup_vm.dart';

class SetupsScreen extends StatefulWidget {
  const SetupsScreen({super.key});

  @override
  State createState() => _SetupsScreenState();
}

class _SetupsScreenState extends State<SetupsScreen> {

  SetupViewModel setupVm = SetupViewModel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 100),
      child: Column (
        children: <Widget> [
          Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Setups', style: TextStyle(fontSize:  36, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(
                icon: const Icon(CupertinoIcons.add_circled, color: Colors.white, size: 36),
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.black)),
                padding: EdgeInsets.zero,
                onPressed: () => setState(() {
                  setupVm.addSetup(
                    Setup(
                      'Setup 1',
                      Telescope('Celestron RASA', 100, 200),
                      Camera('Canon EOS 7D', 1.6, CameraTypes.dslr),
                      true, true)
                  );
                })
              )
            ],
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: setupVm.setupList.length,
            itemBuilder: (BuildContext context, int index) {
              return SetupCard(setupModel: setupVm.setupList.elementAt(index));
            },
          )
        ],
      )
    );
  }

}
