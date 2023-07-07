import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/json_data/weather_data.dart';
import '../../models/plan_m.dart';

class PlanCard extends StatefulWidget {

  final Plan plan;

  final VoidCallback onDelete;

  const PlanCard({super.key, required this.plan, required this.onDelete});

  @override
  State<StatefulWidget> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {

  late Future<WeatherData> weatherFuture;

  @override void initState() {
    super.initState();
    weatherFuture = widget.plan.getFromWeatherApi(requestType: RequestType.forecast);
  }

  @override
  Widget build(BuildContext context) {
    Plan plan = widget.plan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( //Date in E, MM, d
            plan.timespan.formattedRange,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
          ),
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
                    padding: const EdgeInsets.only(left: 12, top: 8, bottom: 12),
                    child: Text(plan.target.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: FutureBuilder<WeatherData> (
                      future: weatherFuture,
                      builder: (context, weatherData) {
                        if(weatherData.hasData){
                          if(weatherData.data?.weatherType == WeatherTypes.good){
                            return const Text('Good weather', style: TextStyle(color: Colors.white));
                          }
                          else {
                            return const Text('Weather bad', style: TextStyle(color: Colors.white));
                          }
                        }
                        else {
                          return const Text('Weather unavailable', style: TextStyle(color: Colors.white));
                        }
                      }
                    )
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.delete, size: 18, color: CupertinoColors.destructiveRed),
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
