import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultTile extends StatefulWidget {
  final int index;

  const ResultTile({super.key, required this.index});

  @override
  State<ResultTile> createState() => _ResultTileState();
}

class _ResultTileState extends State<ResultTile> {
  @override
  Widget build(BuildContext context) {

    final searchVm = Provider.of<SearchViewModel>(context);

    return Card(

    );
  }
}
