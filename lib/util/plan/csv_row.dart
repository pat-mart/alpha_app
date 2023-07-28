import 'package:astro_planner/util/plan/catalog_name.dart';

class CsvRow{

  final Map<String, ObjTypes> objDict = {
    'Galaxy': ObjTypes.galaxy,
    'Planetary Nebula': ObjTypes.p_nebula,
    'Nebula': ObjTypes.nebula,
    'Open Cluster': ObjTypes.o_cluster,

  };

  String catalogName;
  String catalogAlias;

  CsvRow(this.catalogName, this.catalogAlias);
}

enum ObjTypes {
  galaxy,
  p_nebula,
  nebula,
  o_cluster,
  g_cluster,
  c_nebulosity,
  asterism,
  star
}
