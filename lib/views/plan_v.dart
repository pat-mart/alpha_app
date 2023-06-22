import 'package:flutter/material.dart';

import '../models/plan_m.dart';

class PlanCard extends StatefulWidget {

  final Plan plan;

  const PlanCard({super.key, required this.plan});

  @override
  State<StatefulWidget> createState() => PlanCardState();
}

class PlanCardState extends State<PlanCard> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wednesday, June 28', style: TextStyle(color: Colors.white, fontSize: 22)),
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          Card(
              color: const Color(0xFF494949),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: SizedBox (
                  width: double.infinity,
                  height: 120,
                  child: Text(widget.plan.target.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white))
              )
          ),
          const Padding(padding: EdgeInsets.only(bottom: 18))
        ],
      ),
    );
  }

}
