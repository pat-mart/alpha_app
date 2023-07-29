import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  @override
  Widget build(BuildContext context) {

    final searchVm = Provider.of<SearchViewModel>(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Cancel',
        backgroundColor: CupertinoColors.black,
      ),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 14, right: 14, top: 16),
          child: Column(
            children: [
              CupertinoSearchTextField(
                controller: searchVm.controller,
                onSuffixTap: searchVm.clearInput,
                onChanged: searchVm.loadSearchResults,
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
