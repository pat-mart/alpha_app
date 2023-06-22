import 'package:astro_planner/main.dart';
import 'package:flutter/material.dart';

class SetupsScreen extends StatefulWidget {
  const SetupsScreen({super.key});

  @override
  State createState() => _SetupsScreenState();
}

class _SetupsScreenState extends State<SetupsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 14, right: 14, top: 100),
      child: Column (
        children: <Widget> [
          Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Setups', style: TextStyle(fontSize:  36, fontWeight: FontWeight.bold, color: Colors.white)),
              IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 36),
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.black)),
                  padding: EdgeInsets.zero,
                  onPressed: () {}
              )],
          ),
        ],
      )
    );
  }

}
