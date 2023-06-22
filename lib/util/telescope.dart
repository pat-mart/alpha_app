class Telescope {
  String _name;
  double _focalLengthMm;
  double _apertureMm;
  late double _fStop;

  String _cameraName = '';


  Telescope(this._name, this._apertureMm, this._focalLengthMm){
    _fStop = _focalLengthMm / _apertureMm;
  }

  String get name => _name;

  double get focalLengthMm => _focalLengthMm;

  String get cameraName => _cameraName;

  double get fStop => _fStop;

  double get apertureMm => _apertureMm;
}
