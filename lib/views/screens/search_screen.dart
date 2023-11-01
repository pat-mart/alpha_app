import 'dart:io';

import 'package:astro_planner/viewmodels/create_plan/datetime_vm.dart';
import 'package:astro_planner/viewmodels/create_plan/location_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:astro_planner/views/smalls/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {

  final String initialQueryValue;
  final bool isEdit;

  const SearchScreen({super.key, required this.initialQueryValue, required this.isEdit});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController controller = TextEditingController();
  SearchViewModel searchVm = SearchViewModel();

  late HttpClient httpClient;

  @override
  void initState(){
    super.initState();

    httpClient = HttpClient();

    controller.text = widget.initialQueryValue;
  }

  @override
  void dispose(){
    controller.dispose();

    searchVm.clearResults(doNotifyListeners: false);
    searchVm.searchMap.clear();

    httpClient.close(force: true);

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant old){
    super.didUpdateWidget(old);
    SearchViewModel().cancelDeadRequests();
  }

  @override
  Widget build(BuildContext context) {

    final dateTimeVm = DateTimeViewModel();
    final locationVm = LocationViewModel();

    searchVm = Provider.of<SearchViewModel>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'New plan',
        backgroundColor: CupertinoColors.black,
        trailing: CupertinoButton(
          alignment: Alignment.center,
          borderRadius: BorderRadius.zero,
          padding: EdgeInsets.zero,
          onPressed: (searchVm.previewedResult != null && searchVm.previewedResult != searchVm.selectedResult) ? () {
            searchVm.selectResult();
            Navigator.pop(context);
          } : null,
          child: const Text('Select', overflow: TextOverflow.visible)
        ),
      ),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 14, right: 14, top: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CupertinoSearchTextField(
                  controller: controller,
                  onSuffixTap: () {
                    controller.clear();
                    searchVm.clearResults(doNotifyListeners: true);
                  },
                  onChanged: (String q)  {
                    searchVm.loadSearchResults(q);
                  },
                  placeholder: 'Search for a target',
                  autofocus: true,
                ),
              ),
              Expanded(
                child: (searchVm.resultsList.isEmpty && controller.text.isNotEmpty) ? Center(child: Text('No results', style: TextStyle(color: CupertinoColors.secondaryLabel.darkColor)))
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchVm.resultsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if(searchVm.resultsList.isNotEmpty){
                      return SearchResult(index: index, listLength: searchVm.resultsList.length, searchVm: searchVm, dateTimeVm: dateTimeVm, locationVm: locationVm, httpsClient: httpClient);
                    }
                    return null;
                  }
                )
              )
            ]
          )
        )
      )
    );
  }
}
