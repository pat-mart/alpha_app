import 'package:astro_planner/viewmodels/create_plan_vm.dart';
import 'package:astro_planner/viewmodels/search_vm.dart';
import 'package:astro_planner/views/smalls/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController controller = TextEditingController();
  SearchViewModel searchVm = SearchViewModel();

  @override
  void dispose(){
    controller.dispose();
    searchVm.clearResults(doNotifyListeners: false);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final CreatePlanViewModel createPlanVm = Provider.of<CreatePlanViewModel>(context);
    searchVm = Provider.of<SearchViewModel>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'New plan',
        backgroundColor: CupertinoColors.black,
        trailing: CupertinoButton(
            onPressed: (searchVm.selectedResult != null) ? () => Navigator.pop(context) : null,
            child: const Text('Add', overflow: TextOverflow.visible)
        ),
      ),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 14, right: 14, top: 16),
          child: Column(
            children: [
              CupertinoSearchTextField(
                controller: controller,
                onSuffixTap: () {
                  controller.clear();
                  searchVm.clearResults(doNotifyListeners: true);
                },
                onChanged: (String q) async {
                  searchVm.loadSearchResults(q);
                },
                placeholder: 'Search for a target',
                autofocus: true,
              ),
              Expanded(
                child: (searchVm.resultsList.isEmpty && controller.text.isNotEmpty) ? Center(child: Text('No results', style: TextStyle(color: CupertinoColors.systemGrey.darkColor)))
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchVm.resultsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if(searchVm.resultsList.isNotEmpty){
                      return SearchResult(index: index, searchVm: searchVm, createPlanVm: createPlanVm, csvData: searchVm.csvData[index]);
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
