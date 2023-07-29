class CsvRow{

  late String catalogName;
  late String catalogAlias;

  late String objType;
  late String constellation;

  late num magnitude;

  late String properName;

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
