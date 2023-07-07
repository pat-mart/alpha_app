import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sheet extends StatefulWidget {

  final Widget child;

  const Sheet({super.key, required this.child});

  @override
  State createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      child: Container(
        color: const Color(0xFF2C2C2C),
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
