import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PlanSheetHeader extends StatelessWidget {

  final bool isEdit;

  const PlanSheetHeader({super.key, required this.isEdit});

  @override
  Widget build(BuildContext context) {

    return CupertinoSliverNavigationBar(
      automaticallyImplyLeading: false,
      largeTitle: (isEdit) ? const Text('Edit plan') : const Text('New plan'),
      trailing: Material(
        type: MaterialType.transparency,
        borderOnForeground: true,
        child: IconButton(
          padding: const EdgeInsets.only(left: 20),
          icon: const Icon(
            CupertinoIcons.xmark_circle_fill,
            color: CupertinoColors.systemGrey,
            size: 32,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),
    );
  }
}


