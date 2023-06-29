enum CameraTypes {
  dslr,
  astroCmos,
  astroCcd,
}

extension ToString on CameraTypes {
  String asString(){
    return toString().split('.').last.toUpperCase();
  }
}
