import 'package:astro_planner/views/screens/empty_modal_sheet.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/plan_vm.dart';
import '../smalls/plan_sheet_body.dart';
import '../smalls/plan_v.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>{

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      child: CustomScrollView(
        scrollBehavior: const CupertinoScrollBehavior(),
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: CupertinoColors.black,
            padding: EdgeInsetsDirectional.zero,
            largeTitle: const Text('My plans'),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(CupertinoIcons.add_circled, size: 32),
                onPressed: () {
                  setState(() {
                    showCupertinoModalPopup(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: const Color(0xBB000000),
                      builder: (BuildContext context) {
                        return const EmptyModalSheet(child: PlanSheet());
                      }
                    );
                  });
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(left: 14, right: 14),
              child: Consumer<PlanViewModel>(
                builder: (context, planVm, _) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: planVm.modelList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PlanCard(index: index);
                  }
                ),
              ),
            ),
          )]
      ),
    );
  }
}
