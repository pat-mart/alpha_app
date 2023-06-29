import 'package:astro_planner/util/enums/camera_types.dart';

class Camera {

  String _cameraName;

  double _cropFactor;

  CameraTypes _cameraType;

  Camera(this._cameraName, this._cropFactor, this._cameraType);

  String get cameraName => _cameraName;

  double get cropFactor => _cropFactor;

  CameraTypes get cameraType => _cameraType;

  @override
  String toString () => '$_cameraType $cameraName';
}
