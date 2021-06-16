import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/screens/channel_info/channel_info_view_model.dart';
import 'package:sendbird_flutter/screens/channel_info/components/setting_item.dart';
import 'package:sendbird_flutter/screens/channel_info/components/switchable_setting_item.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';

class ChannelInfoScreen extends StatefulWidget {
  final GroupChannel channel;

  ChannelInfoScreen({required this.channel, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChannelInfoScreenState();
}

class _ChannelInfoScreenState extends State<ChannelInfoScreen> {
  late ChannelInfoViewModel model;

  @override
  void initState() {
    super.initState();
    model = ChannelInfoViewModel(widget.channel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _navigationBar(),
      body: ChangeNotifierProvider<ChannelInfoViewModel>(
        create: (context) => model,
        child: Consumer<ChannelInfoViewModel>(
          builder: (context, value, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Column(
                children: [
                  _buildHeader(),
                  Divider(height: 1),
                  SwitchableSettingItem(
                    name: 'Notifications',
                    height: 56,
                    iconImageName: 'assets/iconNotifications@3x.png',
                    iconColor: SBColors.primary_300,
                    iconSize: Size(24, 24),
                    isOn: model.isNotificationOn(channel: widget.channel),
                    onChanged: (value) {
                      model.setNotification(value);
                    },
                  ),
                  Divider(height: 1),
                  SettingItem(
                    name: 'Leave',
                    height: 56,
                    iconColor: Colors.red,
                    iconImageName: 'assets/iconLeave@3x.png',
                    iconSize: Size(24, 24),
                    onTap: () async {
                      final succeeded = await model.leave();
                      if (succeeded)
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName('/channel_list'),
                        );
                    },
                  ),
                  Divider(height: 1),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _navigationBar() {
    return AppBar(
      leading: BackButton(color: Theme.of(context).primaryColor),
      toolbarHeight: 65,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text(
        'Channel Information',
        style: TextStyles.sendbirdH2OnLight1,
      ),
      actions: [
        TextButton(
          child: Text(
            "Edit",
            style: TextStyles.sendbirdBody1Primary300,
          ),
          onPressed: () => model.showChannelOptions(context),
        )
      ],
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            AvatarView(
              channel: widget.channel,
              width: 80,
              height: 80,
            ),
            SizedBox(height: 8),
            Text(
              widget.channel.name ?? 'channel name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.sendbirdH1OnLight1,
            )
          ],
        ),
      ),
    );
  }
}
