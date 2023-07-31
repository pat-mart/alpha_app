class CsvRow{

  String catalogName = '';
  String catalogAlias = '';

  String objType = '';
  String constellation = '';

  num magnitude = 0.0;

  String properName = '';

  CsvRow({required this.catalogName, required this.catalogAlias, required this.objType, required this.constellation,
      required this.magnitude, required this.properName});

  CsvRow.empty(){
    catalogName = '';
    catalogAlias = '';

    objType = '';
    constellation = '';

    magnitude = 0;

    properName = '';
  }
}
