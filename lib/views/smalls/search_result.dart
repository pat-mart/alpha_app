import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';

class SearchResult extends StatefulWidget {
  final int index;
  const SearchResult({super.key, required this.index});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  @override
  Widget build(BuildContext context) {

    SearchViewModel vm = SearchViewModel();
    var instance = vm.resultsList.elementAt(widget.index);

    bool hasProperName = instance.properName.isNotEmpty;
    bool hasCatalogAlias = instance.catalogAlias.isNotEmpty;

    String properName = instance.properName.contains(",")
        ? instance.properName.substring(0, instance.properName.indexOf(","))
        : instance.properName;

    return CupertinoListTile.notched(
      title: Text(hasProperName ? properName : instance.catalogName),
      backgroundColorActivated: CupertinoColors.activeBlue,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hasCatalogAlias
              ? "${instance.catalogName}, ${instance.catalogAlias}"
              : instance.catalogName
          )
        ],
      ),
    );
  }
}
