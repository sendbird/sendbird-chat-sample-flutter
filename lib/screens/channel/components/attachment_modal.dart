import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';

class AttachmentModal {
  final BuildContext context;

  AttachmentModal({required this.context});

  Future<File> getFile() {
    final wait = Completer<File>();

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: Text(
                      'Camera',
                      style: TextStyles.sendbirdBody1OnLight1,
                    ),
                    trailing: ImageIcon(
                      AssetImage('assets/iconCamera@3x.png'),
                      color: SBColors.primary_300,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final res = await _showPicker(ImageSource.camera);
                      wait.complete(res);
                    }),
                ListTile(
                    title: Text(
                      'Photo & Video Library',
                      style: TextStyles.sendbirdBody1OnLight1,
                    ),
                    trailing: ImageIcon(
                      AssetImage('assets/iconPhoto@3x.png'),
                      color: SBColors.primary_300,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final res = await _showPicker(ImageSource.gallery);
                      wait.complete(res);
                    }),
                ListTile(
                  title: Text('Cancel'),
                  onTap: () {
                    Navigator.pop(context);
                    wait.complete(null);
                  },
                ),
              ],
            ),
          ));
        });

    return wait.future;
  }

  Future<File?> _showPicker(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
