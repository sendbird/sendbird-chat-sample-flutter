import 'package:app/components/app_bar.dart';
import 'package:app/components/dialog.dart';
import 'package:app/components/padding.dart';
import 'package:app/requests/channel_requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/core/channel/base/base_channel.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChatDetailRoute extends StatefulWidget {
  const ChatDetailRoute({Key? key}) : super(key: key);

  @override
  ChatDetailRouteState createState() => ChatDetailRouteState();
}

class ChatDetailRouteState extends State<ChatDetailRoute> {
  late final TextEditingController _channelNameController;
  late final BaseChannel _channel;

  @override
  void initState() {
    _channelNameController = TextEditingController();
    _channel = Get.arguments[0];
    super.initState();
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
        title: 'Chat Room Detail',
        includeLeading: false,
      ),
      body: paddingComponent(
          widget: Column(
        children: [
          const Spacer(),
          TextField(
            controller: _channelNameController,
            decoration: const InputDecoration(
              hintText: 'Channel Name',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const Spacer(),
          TextButton(
              onPressed: () async {
                Object params;
                switch (_channel.channelType) {
                  case ChannelType.group:
                    params = GroupChannelParams()
                      ..name = _channelNameController.value.text;
                    break;
                  case ChannelType.open:
                    params = OpenChannelParams()
                      ..name = _channelNameController.value.text;
                    break;
                }
                await editChannel(channel: _channel, params: params);
                if (!mounted) {
                  Get.back();
                } else {
                  // ignore: use_build_context_synchronously
                  dialogComponent(context,
                      type: DialogType.oneButton, title: 'Saved', onTap1: () {
                    Get.back();
                  });
                }
              },
              child: const Text('Save')),
          const SizedBox(height: 12),
          TextButton(
              onPressed: () async {
                await deleteChannel(channel: _channel);
                switch (_channel.channelType) {
                  case ChannelType.group:
                    Get.offAllNamed('/GroupChannelRoute')?.then((value) {
                      setState(() {});
                    });
                    break;
                  case ChannelType.open:
                    Get.offAllNamed('/OpenChannelRoute')?.then((value) {
                      setState(() {});
                    });
                    break;
                }
              },
              child: const Text('Leave Room')),
          const SizedBox(height: 100),
        ],
      )),
    );
  }
}
