import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showData(BuildContext context, String data) {
  showCupertinoDialog(
      builder: (context) => CupertinoAlertDialog(
        content: Stack(
          children: [
            CupertinoTextField(
              controller: TextEditingController(text: data),
              readOnly: true,
            ),
            Align(
              alignment: Alignment.topRight,
              child: CupertinoButton(
                  child: Icon(Icons.copy, size: 15),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data));
                  }
              ),
            )
          ],
        ),
        actions: [
          CupertinoButton(child: Text("OK"), onPressed: () => Navigator.pop(context))
        ],
      ),
      barrierDismissible: true,
      context: context
  );
}