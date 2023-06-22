import 'package:astro_planner/util/telescope.dart';

class SetupModel {
  Telescope _telescope;

  String _setupName;

  double _cropFactor = 1;

  bool _isGuided;

  bool _isEq;

  SetupModel(this._setupName, this._telescope, this._cropFactor, this._isGuided, this._isEq);

  Telescope get telescope => _telescope;

  String get setupName => _setupName;

  double get cropFactor => _cropFactor;

  bool get isGuided => _isGuided;

  bool get isEq => _isEq;
}
