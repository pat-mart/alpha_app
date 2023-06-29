import 'package:astro_planner/models/setup_m.dart';
import 'package:flutter/material.dart';

class SetupCard extends StatefulWidget {

  final SetupModel setupModel;

  const SetupCard({super.key, required this.setupModel});

  @override
  State<StatefulWidget> createState() => _SetupCardState();
}

class _SetupCardState extends State<SetupCard> {

  int fontSize = 16;

  @override
  Widget build(BuildContext context){
    return Card(
      color: const Color(0xFF494949),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox (
        width: double.infinity,
        height: 164,
        child: Container(
          margin: const EdgeInsets.only(left: 12, right: 12, top: 0),
          child: Column (
            children: [
              Row(
                children: [
                  Text( //Setup title
                    widget.setupModel.setupName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 50))
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Row(
                        children: [
                          const Icon(Icons.insights, size: 18, color: Colors.white),
                          const Padding(padding: EdgeInsets.only(left: 8)),
                          Text( // Telescope information
                              widget.setupModel.telescope.toString(),
                              style: const TextStyle(fontSize: 14, color: Colors.white)
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 16)),
                      Row(
                        children: [
                          const Icon(Icons.looks, size: 18, color: Colors.white),
                          const Padding(padding: EdgeInsets.only(left: 8)),
                          Text(
                              (widget.setupModel.isEq) ? 'Equatorial' : 'Alt-azimuth',
                              style: const TextStyle(fontSize: 14, color: Colors.white)
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(right: 32)),
                  Column (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Row(
                        children: [
                          const Icon(Icons.local_see_outlined),
                          const Padding(padding: EdgeInsets.only(left: 8)),
                          Text( // Camera information
                              widget.setupModel.camera.cameraName,
                              style: const TextStyle(fontSize: 14, color: Colors.white)
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 16)),
                      Row(
                        children: [
                          const Icon(Icons.motion_photos_on_outlined,),
                          const Padding(padding: EdgeInsets.only(left: 8)),
                          Text(
                              (widget.setupModel.isGuided) ? 'Auto-guided' : 'Not auto-guided',
                              style: const TextStyle(fontSize: 14, color: Colors.white)
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
      )
    );
  }
}
