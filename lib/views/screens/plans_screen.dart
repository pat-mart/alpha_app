import 'dart:async';
import 'dart:io';

import 'package:astro_planner/views/screens/empty_modal_sheet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/plan_m.dart';
import '../../viewmodels/plan_vm.dart';
import '../smalls/plan_v.dart';
import 'plan_sheet_body.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late Future<List<Plan>> planListFuture;

  final httpsClient = HttpClient();

  late final StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();

    planListFuture = PlanViewModel().savedPlans;

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if ([
        ConnectivityResult.wifi,
        ConnectivityResult.ethernet,
        ConnectivityResult.mobile,
        ConnectivityResult.other
      ].contains(result)) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        scrollBehavior: const CupertinoScrollBehavior(),
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: CupertinoColors.black,
            largeTitle: const Text('Plans'),
            trailing: IconButton(
              icon: const Icon(CupertinoIcons.add_circled, size: 32),
              onPressed: () async {
                if ((await PlanViewModel().savedPlans).length >= 64) {
                  setState(() {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text('Maximum plan number reached'),
                        ),
                        content:
                            const Text('You can store a maximum of 64 plans'),
                        actions: [
                          CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'))
                        ],
                      ),
                    );
                  });
                }
                setState(() {
                  showCupertinoModalPopup(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: CupertinoColors.black,
                    builder: (BuildContext context) {
                      return const EmptyModalSheet(child: PlanSheet());
                    },
                  );
                });
              },
            ),
          ),
          SliverToBoxAdapter(
              child: SafeArea(
                  child: Container(
                      margin: const EdgeInsets.only(left: 14, right: 14),
                      child: Consumer<PlanViewModel>(
                          builder: (context, planVm, _) => FutureBuilder(
                              future: planListFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    !snapshot.hasError &&
                                    snapshot.data != null) {
                                  planVm.planList = snapshot.data!;
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data == null
                                          ? 0
                                          : snapshot.data!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return PlanCard(
                                            index: index,
                                            httpsClient: httpsClient);
                                      });
                                } else if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    !snapshot.hasError) {
                                  return const CupertinoActivityIndicator();
                                } else {
                                  return const Text('Error loading saved plans',
                                      style: TextStyle(
                                          color: CupertinoColors.white));
                                }
                              })))))
        ]);
  }
}
