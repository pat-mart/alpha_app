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
    return SafeArea(
      bottom: false,
      child: CupertinoPopupSurface(
        child: CupertinoPageScaffold(
          resizeToAvoidBottomInset: true,
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1.175,
            width: MediaQuery.of(context).size.width,
            child: Container(
              margin: const EdgeInsets.only(left: 14, right: 14),
              child: widget.child
            )
          ),
        ),
      ),
    );
  }
}
