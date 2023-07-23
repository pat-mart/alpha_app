import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/empty_modal_sheet.dart';

class EditSheet extends StatefulWidget {

  final VoidCallback onAddSetup;

  const EditSheet({super.key, required this.onAddSetup});

  @override
  State<EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<EditSheet> {
  @override
  Widget build(BuildContext context) {
    return EmptyModalSheet (
      child: Column (
        children: [
          Row (
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                padding: const EdgeInsets.only(left: 14, bottom: 14),
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () => Navigator.pop(context)
              )
            ],
          ),
          const Row (
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Add new setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white))
              )
            ]
          ),
          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Text('Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                SearchBar(hintText: 'Dummy text', constraints: BoxConstraints(maxWidth: 330), backgroundColor: MaterialStatePropertyAll<Color>(CupertinoColors.inactiveGray))
              ],
            ),
          ),
        ],
      )
    );
  }
}
