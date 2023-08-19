import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyModalSheet extends StatefulWidget {

  final Widget child;

  const EmptyModalSheet({super.key, required this.child});

  @override
  State createState() => _EmptyModalSheetState();
}

class _EmptyModalSheetState extends State<EmptyModalSheet> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: Container(
        height: MediaQuery.of(context).size.height - 50,
        width: MediaQuery.of(context).size.width,
        color: CupertinoColors.systemGroupedBackground.darkElevatedColor,
        child: Container(
          margin: const EdgeInsets.only(left: 14, right: 14),
          child: widget.child
        )
      ),
    );
  }
}
