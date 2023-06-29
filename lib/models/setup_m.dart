import 'package:astro_planner/util/setup/telescope.dart';

import '../util/setup/camera.dart';

class SetupModel {

  Telescope _telescope;

  Camera _camera;

  String _setupName;

  bool _isGuided, _isEq;

  SetupModel(this._setupName, this._telescope, this._camera, this._isGuided, this._isEq);

  Telescope get telescope => _telescope;

  Camera get camera => _camera;

  String get setupName => _setupName;

  bool get isGuided => _isGuided;

  bool get isEq => _isEq;
}
