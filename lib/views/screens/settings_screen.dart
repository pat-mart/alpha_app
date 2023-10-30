import 'package:astro_planner/views/screens/settings_body.dart';
import 'package:flutter/cupertino.dart';

class SettingsScreen extends StatelessWidget {

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
         CupertinoSliverNavigationBar(
          backgroundColor: CupertinoColors.black,
          largeTitle: Text('Settings'),
        ),
        SliverToBoxAdapter(
          child: SafeArea(
            child: SettingsBody()
          ),
        )
      ],
    );
  }
}
