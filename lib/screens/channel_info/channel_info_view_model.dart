import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbird_flutter/utils/utils.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart' as s;

class ChannelInfoViewModel with ChangeNotifier, s.ChannelEventHandler {
  final sdk = s.SendbirdSdk();
  final textController = TextEditingController();

  BuildContext _context;
  s.GroupChannel channel;

  ChannelInfoViewModel(s.GroupChannel channel) {
    sdk.addChannelHandler('channel_info_view', this);
  }

  bool isNotificationOn({s.GroupChannel channel}) {
    return channel.myPushTriggerOption != s.GroupChannelPushTriggerOption.off;
  }

  Future<void> setNotification(bool value) async {
    if (channel == null) return;

    try {
      final option = value
          ? s.GroupChannelPushTriggerOption.all
          : s.GroupChannelPushTriggerOption.off;
      await channel.setMyPushTriggerOption(option);
      notifyListeners();
    } catch (e) {
      //e
    }
  }

  Future<bool> leave() async {
    if (channel == null) return false;

    try {
      await channel.leave();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateChannel(
      {s.GroupChannel channel, String name, File file}) async {
    if (name == '' && file == null) {
      return;
    }

    showLoader(_context);

    try {
      final params = s.GroupChannelParams()..name = name;
      if (file != null) {
        params.coverImage = s.ImageInfo.fromData(
          name: 'image name',
          file: file,
          mimeType: 'image/jpeg',
        );
      }
      await channel.updateChannel(params);
      Navigator.pop(_context);
      notifyListeners();
    } catch (e) {
      Navigator.pop(_context);
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
            FlatButton(
              child: Text("Cancel"),
              color: SBColors.primary_300,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("OK"),
              color: SBColors.primary_300,
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
  void onChannelChanged(s.BaseChannel channel) {
    notifyListeners();
  }
}
