import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbird_flutter/main.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbird_flutter/utils/utils.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChannelInfoViewModel with ChangeNotifier, ChannelEventHandler {
  final textController = TextEditingController();

  BuildContext? _context;
  GroupChannel channel;

  ChannelInfoViewModel(this.channel) {
    sendbird.addChannelEventHandler('channel_info_view', this);
  }

  void dispose() {
    super.dispose();
    sendbird.removeChannelEventHandler('channel_info_view');
  }

  bool isNotificationOn({required GroupChannel channel}) {
    return channel.myPushTriggerOption != GroupChannelPushTriggerOption.off;
  }

  Future<void> setNotification(bool value) async {
    try {
      final option = value
          ? GroupChannelPushTriggerOption.all
          : GroupChannelPushTriggerOption.off;
      await channel.setMyPushTriggerOption(option);
      notifyListeners();
    } catch (e) {
      //e
    }
  }

  Future<bool> leave() async {
    try {
      await channel.leave();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateChannel({String? name, File? file}) async {
    if (name == '' && file == null) {
      return;
    }
    final context = _context;
    if (context == null) return;

    showLoader(context);

    try {
      final params = GroupChannelParams()..name = name;
      if (file != null) {
        params.coverImage = FileInfo.fromData(
          name: 'image name',
          file: file,
          mimeType: 'image/jpeg',
        );
      }
      await channel.updateChannel(params);
      Navigator.pop(context);
      notifyListeners();
    } catch (e) {
      Navigator.pop(context);
    }
  }

  void showChannelOptions(BuildContext context) {
    _context = context;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
            child: Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  title: new Text(
                    'Change channel name',
                    style: TextStyles.sendbirdBody1OnLight1,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showChannelNameEditDialog(context);
                  }),
              ListTile(
                  title: new Text(
                    'Change channel image',
                    style: TextStyles.sendbirdBody1OnLight1,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  }),
              ListTile(
                title: new Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ));
      },
    );
  }

  void showChannelNameEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Change channel name',
            style: TextStyles.sendbirdH2OnLight1,
          ),
          content: TextField(
            onChanged: (value) {},
            controller: textController,
            decoration: InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: SBColors.primary_300),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(color: SBColors.primary_300),
              ),
              onPressed: () {
                Navigator.pop(context);
                updateChannel(name: textController.text);
              },
            )
          ],
        );
      },
    );
  }

  void showPicker(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      updateChannel(file: File(pickedFile.path));
    }
  }

  @override
  void onChannelChanged(BaseChannel channel) {
    notifyListeners();
  }
}
