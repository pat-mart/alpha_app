import 'package:flutter/material.dart';

import '../../models/plan_m.dart';

class PlanCard extends StatefulWidget {

  final Plan plan;

  final VoidCallback onDelete;

  const PlanCard({super.key, required this.plan, required this.onDelete});

  @override
  State<StatefulWidget> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SizedBox (
                width: double.infinity,
                height: MediaQuery.of(context).size.height/6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 8),
                      child: Text(widget.plan.target.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, size: 18, color: Colors.white),
                      onPressed: widget.onDelete
                    )
                  ],
                )
              )
          ),
          const Padding(padding: EdgeInsets.only(bottom: 18))
        ],
      ),
    );
  }

}
