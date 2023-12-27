import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {

  double heading = 0.0; // Not very MVVM, but best to keep simple things simple
  double yAxisTilt = 0.0;

  late final StreamSubscription<GyroscopeEvent> gyroStream;

  @override
  void initState(){
    super.initState();

    gyroStream = gyroscopeEventStream().listen((event) {
      yAxisTilt = event.x;
      heading = event.y;
    });
  }

  @override
  void dispose() {
    gyroStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          backgroundColor: CupertinoColors.black,
          largeTitle: Text('Compass'),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Text("$yAxisTilt", style: const TextStyle(color: CupertinoColors.white)),
              Text("$heading", style: const TextStyle(color: CupertinoColors.white))
            ],
          )
        )
      ]
    );
  }
}
