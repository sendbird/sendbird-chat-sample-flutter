import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum DialogType {
  oneButton,
  twoButton,
}

Future<void> dialogComponent(
  BuildContext context, {
  DialogType type = DialogType.twoButton,
  String? title,
  String? content,
  Function? onTap1,
  String? buttonText1,
  Function? onTap2,
  String? buttonText2,
}) async {
  switch (type) {
    case DialogType.oneButton:
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title == null ? null : Text(title),
            content: content == null ? null : Text(content),
            actions: <Widget>[
              TextButton(
                child: Text(buttonText1 ?? 'Approve'),
                onPressed: () async {
                  if (onTap1 != null) {
                    await onTap1();
                  }
                  Get.back();
                },
              ),
            ],
          );
        },
      ).then((value) {
        //TODO
      });
      break;
    case DialogType.twoButton:
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title == null ? null : Text(title),
            content: content == null ? null : Text(content),
            actions: <Widget>[
              TextButton(
                child: Text(buttonText1 ?? 'Approve'),
                onPressed: () async {
                  if (onTap1 != null) {
                    await onTap1();
                  }
                  Get.back();
                },
              ),
              TextButton(
                child: Text(buttonText2 ?? 'Cancel'),
                onPressed: () async {
                  if (onTap2 != null) {
                    await onTap2();
                  }
                  Get.back();
                },
              ),
            ],
          );
        },
      ).then((value) {
        //TODO
      });
      break;
  }
}
