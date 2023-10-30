import 'dart:io';

import 'package:astro_planner/models/json_data/skyobj_data.dart';
import 'package:astro_planner/models/plan_m.dart';
import 'package:astro_planner/models/sky_obj_m.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plan', () {
    test('timely api call', () async {

      final SkyObj andromeda = SkyObj(catalogName: 'NGC224', catalogAlias: 'M 31', objType: 'galaxy', constellation: 'andromeda', magnitude: 3.2, properName: 'Andromeda Galaxy', isStar: false);

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
      final httpClient = HttpClient();

      await test.getObjInfo(1, 0, httpClient);

      expect(test.skyObjData.runtimeType, SkyObjectData);
    });

    test('ten api calls', () async {

    });
  });
}