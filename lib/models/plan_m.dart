import 'package:astro_planner/models/setup_m.dart';
import 'package:astro_planner/models/sky_object_m.dart';

class Plan {
  late SkyObject _target;
  late SetupModel _setup;

  Plan(this._target, this._setup);

  SkyObject get target => _target;

  SetupModel get setup => _setup;
}
