import 'catalog_types.dart';

class CatalogName {

  late final CatalogTypes _type;
  late final int _num;

  CatalogName(this._type, this._num);

  CatalogName.none(){
    _type = CatalogTypes.none;
    _num = 0;
  }

  CatalogTypes get type => _type;

  int get num => _num;
}
