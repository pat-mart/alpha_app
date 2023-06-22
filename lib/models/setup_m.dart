import 'package:astro_planner/util/telescope.dart';

class SetupModel {
  Telescope _telescope;

  double _cropFactor = 1;

  bool _isGuided;

  SetupModel(this._telescope, this._cropFactor, this._isGuided);

  Telescope get telescope => _telescope;

  double get cropFactor => _cropFactor;

  bool get isGuided => _isGuided;
}
