enum CatalogTypes {
  messier,
  ngc,
  ic,
  none
}

extension ToString on CatalogTypes {
  String asString(){
    return toString().split('.').last.titleCase();
  }
}

extension Titleize on String {
  String titleCase(){
    return this[0].toUpperCase() + substring(1);
  }
}
