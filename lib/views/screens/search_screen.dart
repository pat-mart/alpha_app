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
                controller: controller,
                onSuffixTap: () {
                  controller.clear();
                  searchVm.clearResults(doNotifyListeners: true);
                },
                onChanged: searchVm.loadSearchResults,
                placeholder: 'Search for a target',
                autofocus: true,
              ),
              Expanded(
                child: Consumer<SearchViewModel>(
                  builder: (context, searchVm, _) => ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchVm.resultsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if(searchVm.resultsList.isNotEmpty){
                        return SearchResult(index: index);
                      }
                      return const Text('Object not available');
                    },
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
