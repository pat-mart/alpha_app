import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    // final _vm = Provider.of<PlanViewModel>(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Cancel',
      ),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 14, right: 14, top: 16),
          child: const Column(
            children: [
              CupertinoSearchTextField(
                placeholder: 'Search for a target',
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
