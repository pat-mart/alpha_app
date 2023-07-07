import 'package:flutter/cupertino.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Cancel',
      ),
      child: Column(
        children: <Widget> [
          Expanded(
            child: CupertinoSearchTextField(
              placeholder: 'Placeholder',
              autofocus: true,
            ),
          )
        ],
      )
    );
  }
}
