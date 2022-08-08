import 'package:app/components/app_bar.dart';
import 'package:app/components/dialog.dart';
import 'package:app/components/padding.dart';
import 'package:app/requests/message_requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class EditMessageRoute extends StatefulWidget {
  final UserMessage message;
  final dynamic channel;
  const EditMessageRoute(
      {Key? key, required this.message, required this.channel})
      : super(key: key);

  @override
  EditMessageRouteState createState() => EditMessageRouteState();
}

class EditMessageRouteState extends State<EditMessageRoute> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(includeLeading: false, title: 'Edit Message'),
      body: paddingComponent(
        widget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: widget.message.message,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (_messageController.value.text.isNotEmpty) {
                  await editUserMessage(
                    channel: widget.channel,
                    messageId: widget.message.messageId,
                    params: UserMessageParams(
                        message: _messageController.value.text),
                  );
                  Get.back();
                } else {
                  dialogComponent(
                    context,
                    type: DialogType.oneButton,
                    title: 'Empty Text. Please input text.',
                  );
                }
              },
              child: const Text('Save Change'),
            )
          ],
        ),
      ),
    );
  }
}
