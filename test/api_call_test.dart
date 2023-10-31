import 'dart:io';
import 'dart:math';

import 'package:astro_planner/models/json_data/skyobj_data.dart';
import 'package:astro_planner/models/plan_m.dart';
import 'package:astro_planner/models/sky_obj_m.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Plan API testing', () {

    final SkyObj andromeda = SkyObj(catalogName: 'NGC224', catalogAlias: 'M 31', objType: 'galaxy', constellation: 'andromeda', magnitude: 3.2, properName: 'Andromeda Galaxy', isStar: false);

    test('timely api call', () async {

      final httpClient = HttpClient();

      Plan test = Plan(
        andromeda,
        DateTime.now(),
        DateTime.now(),
        40.8,
        -73.1,
        'EST',
        null,
        false,
        20,
        150,
        200,
        'blahblahblah'
      );

      await test.getObjInfo(1, 0, httpClient);

      expect(test.skyObjData.runtimeType, SkyObjectData);
    });

    test('multiple simultaneous api calls', () async {

      final httpClient = HttpClient();

      List<Plan> planList = List.empty(growable: true);
      List<dynamic> dataList = List.empty(growable: true);

      for(int i = 0; i < 8; i++){
        planList.add(
            Plan(
                andromeda,
                DateTime.now(),
                DateTime.now(),
                Random().nextDouble() * -90,
                Random().nextDouble() * -180,
                'EST',
                null,
                false,
                20,
                150,
                200,
                Uuid().v4()
            )
        );
      }

      for(final plan in planList){
        try {
          var data = await plan.getObjInfo(10, 1, httpClient);
          dataList.add(data);
        } catch(e) {
          print(e);
          print(plan.latitude);
          print(plan.longitude);
        }
      }

      for(dynamic element in dataList){
        expect(element.runtimeType, SkyObjectData);
      }
    });
  });
}