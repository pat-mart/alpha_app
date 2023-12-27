class SkyObj{

  String catalogName = '';
  String catalogAlias = '';

  String constellation = '';

  num magnitude = 0.0;

  double ra = 0.0;
  double dec = 0.0;

  String properName = '';

  bool isStar = false;
  bool isPlanet = false;

  SkyObj({required this.catalogName, required this.catalogAlias, required this.constellation,
      required this.magnitude, required this.properName, required this.isStar, required this.isPlanet, required this.ra, required this.dec});

  SkyObj.empty(){
    catalogName = '';
    catalogAlias = '';

    constellation = '';

    magnitude = 0;

    properName = '';
  }

  factory SkyObj.fromString(String str){
    List<String> list = str.split('*');

    if(list.length == 7){
      return SkyObj(
        properName: list[0],
        catalogName: list[1],
        catalogAlias: list[2],
        constellation: list[4],
        magnitude: num.tryParse(list[5]) ?? double.nan,
        isStar: list[6] == 'true',
        isPlanet: false,
        ra: double.nan,
        dec: double.nan
      );
    }

    return SkyObj(
        properName: list[0],
        catalogName: list[1],
        catalogAlias: list[2],
        constellation: list[3],
        magnitude: num.tryParse(list[4]) ?? double.nan,
        isStar: list[5] == 'true',
        isPlanet: list[8] == 'true',
        ra: double.parse(list[6]),
        dec: double.parse(list[7]),
    );
  }

  @override
  String toString(){
    return '$properName*$catalogName*$catalogAlias*$constellation*$magnitude*$isStar*$ra*$dec*$isPlanet';
  }

  @override
  bool operator ==(Object other) {
    return toString() == other.toString();
  }
}
