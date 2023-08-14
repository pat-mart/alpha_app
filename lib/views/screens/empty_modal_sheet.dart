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
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        width: MediaQuery.of(context).size.width,
        child: Container(
          margin: const EdgeInsets.only(left: 14, right: 14),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: widget.child
          ),
        )
      ),
    );
  }
}
