enum CatalogTypes {
  messier,
  ngc,
  ic,
  hd,
  none
}

extension ToTitleized on CatalogTypes {
  String asTitleized(){
    return toString().split('.').last.titleCase();
  }
}

extension ToUppercase on CatalogTypes {
  String asUppercase(){
    return toString().split('.').last.toUpperCase();
  }
}

extension Titleize on String {
  String titleCase(){
    return this[0].toUpperCase() + substring(1);
  }
}
