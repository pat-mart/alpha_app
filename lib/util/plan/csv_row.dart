import 'package:uuid/uuid.dart';

class CsvRow{

  String catalogName = '';
  String catalogAlias = '';

  String objType = '';
  String constellation = '';

  num magnitude = 0.0;

  String properName = '';

  bool isStar = false;

  CsvRow({required this.catalogName, required this.catalogAlias, required this.objType, required this.constellation,
      required this.magnitude, required this.properName, required this.isStar});

  CsvRow.empty(){
    catalogName = '';
    catalogAlias = '';

    objType = '';
    constellation = '';

    magnitude = 0;

    properName = '';
  }
}
