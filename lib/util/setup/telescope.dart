class Telescope {

  String _name;

  double _focalLengthMm, _apertureMm;

  late double _fStop;

  Telescope(this._name, this._apertureMm, this._focalLengthMm){
    _fStop = _focalLengthMm / _apertureMm;
  }

  String get name => _name;

  double get focalLengthMm => _focalLengthMm;

  double get fStop => _fStop;

  double get apertureMm => _apertureMm;

  @override
  String toString(){
    return '$name $focalLengthMm';
  }
}
