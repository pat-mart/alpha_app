class SkyObj{

  String catalogName = '';
  String catalogAlias = '';

  String objType = '';
  String constellation = '';

  num magnitude = 0.0;

  String properName = '';

  bool isStar = false;

  SkyObj({required this.catalogName, required this.catalogAlias, required this.objType, required this.constellation,
      required this.magnitude, required this.properName, required this.isStar});

  SkyObj.empty(){
    catalogName = '';
    catalogAlias = '';

    objType = '';
    constellation = '';

    magnitude = 0;

    properName = '';
  }

  factory SkyObj.fromString(String str){
    List<String> list = str.split('*');

    return SkyObj(
      properName: list[0],
      catalogName: list[1],
      catalogAlias: list[2],
      objType: list[3],
      constellation: list[4],
      magnitude: num.tryParse(list[5]) ?? double.nan,
      isStar: list[6] == 'true'
    );
  }

  @override
  String toString(){
    return '$properName*$catalogName*$catalogAlias*$objType*$constellation*$magnitude*$isStar';
  }
}
