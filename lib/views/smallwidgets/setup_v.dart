import 'package:astro_planner/models/setup_m.dart';
import 'package:flutter/material.dart';

class SetupCard extends StatefulWidget {

  final SetupModel setupModel;

  const SetupCard({super.key, required this.setupModel});

  @override
  State<StatefulWidget> createState() => _SetupCardState();
}

class _SetupCardState extends State<SetupCard> {

  @override
  Widget build(BuildContext context){
    return Card(
      color: const Color(0xFF494949),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox (
        width: double.infinity,
        height: 100,
        child: Column (
          children: [
            Row(
              children: [
                Text(
                  widget.setupModel.setupName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                ),
                const Padding(padding: EdgeInsets.only(bottom: 14))
              ],
            ),
            Row(
              children: <Widget> [
                const Icon(Icons.insights, size: 18, color: Colors.white),
                Text(
                  widget.setupModel.telescope.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.white)
                ),
                const Padding(padding: EdgeInsets.only(right: 16)),
                const Icon(Icons.local_see_outlined),
                Text(
                  widget.setupModel.telescope.cameraName,
                  style: const TextStyle(fontSize: 14, color: Colors.white)
                )
              ]
            ),
            Row(
              children: <Widget> [
                const Icon(Icons.looks, size: 18, color: Colors.white),
                Text(
                    (widget.setupModel.isEq) ? 'Equatorial' : 'Alt-azimuth',
                    style: const TextStyle(fontSize: 14, color: Colors.white)
                ),
                const Padding(padding: EdgeInsets.only(right: 16)),
                const Icon(Icons.motion_photos_on_outlined),
                Text(
                    (widget.setupModel.isGuided) ? 'Auto-guided' : 'Not auto-guided',
                    style: const TextStyle(fontSize: 14, color: Colors.white)
                )
              ]
            )
          ],
        )
      )
    );
  }
}
