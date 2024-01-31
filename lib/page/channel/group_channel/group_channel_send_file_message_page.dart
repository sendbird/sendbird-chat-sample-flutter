// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class GroupChannelSendFileMessagePage extends StatefulWidget {
  const GroupChannelSendFileMessagePage({Key? key}) : super(key: key);

  @override
  State<GroupChannelSendFileMessagePage> createState() =>
      _GroupChannelSendFileMessagePageState();

  static Future<void> showDialogToResendFileMessage({
    required BuildContext context,
    required GroupChannel? groupChannel,
    required FileMessage message,
    bool goBackAfterSent = true,
  }) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Text(
                'Resend: ${message.messageCreateParams?.fileInfo.fileName}'),
            actions: [
              TextButton(
                onPressed: () {
                  groupChannel?.resendFileMessage(
                    message,
                    handler: (message, e) async {
                      if (e != null) {
                        await showDialogToResendFileMessage(
                          context: context,
                          groupChannel: groupChannel,
                          message: message,
                        );
                      } else {
                        if (goBackAfterSent) {
                          Get.back();
                        }
                      }
                    },
                  );

                  Get.back();
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }
}

class _GroupChannelSendFileMessagePageState
    extends State<GroupChannelSendFileMessagePage> {
  final channelUrl = Get.parameters['channel_url']!;
  final textEditingController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();

  String title = 'Send FileMessage';
  double? uploadProgressValue;

  Uint8List? fileBytes; // For Web
  String? filePath; // For Android and iOS

  GroupChannel? groupChannel;

  @override
  void initState() {
    super.initState();

    GroupChannel.getChannel(channelUrl).then((channel) {
      groupChannel = channel;
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle(title),
        actions: [
          if (fileBytes != null || filePath != null)
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () async {
                FileMessageCreateParams? params;
                if (kIsWeb && fileBytes != null) {
                  params = FileMessageCreateParams.withFileBytes(
                    fileBytes!,
                    fileName: textEditingController.text,
                  );
                } else if (filePath != null) {
                  params = FileMessageCreateParams.withFile(
                    File(filePath!),
                    fileName: textEditingController.text,
                  );
                }

                if (params != null) {
                  groupChannel?.sendFileMessage(
                    params,
                    handler: (message, e) async {
                      if (e != null) {
                        if (!SendbirdChat.getOptions().useCollectionCaching) {
                          await GroupChannelSendFileMessagePage
                              .showDialogToResendFileMessage(
                            context: context,
                            groupChannel: groupChannel,
                            message: message,
                          );
                        } else {
                          Get.back();
                        }
                      } else {
                        Get.back();
                      }
                    },
                    progressHandler: (sentBytes, totalBytes) {
                      setState(() {
                        uploadProgressValue = (sentBytes / totalBytes);
                      });
                    },
                  );
                }
              },
            ),
        ],
      ),
      body: _sendFileMessageBox(),
    );
  }

  Widget _sendFileMessageBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Widgets.textField(
              textEditingController,
              'File Name',
              focusNode: textFieldFocusNode,
            ),
          ),
          const SizedBox(width: 8.0),
          (uploadProgressValue != null)
              ? CircularProgressIndicator(value: uploadProgressValue)
              : ElevatedButton(
                  onPressed: () async {
                    textFieldFocusNode.unfocus();

                    final result = await FilePicker.platform
                        .pickFiles(type: FileType.any, allowMultiple: false);

                    if (result != null && result.files.isNotEmpty) {
                      if (kIsWeb) {
                        fileBytes = result.files.single.bytes;
                      } else {
                        filePath = result.files.single.path;
                      }

                      if (fileBytes != null || filePath != null) {
                        setState(() {
                          textEditingController.text = result.files.first.name;
                        });
                      }
                    }
                  },
                  child: const Text('Pick'),
                ),
        ],
      ),
    );
  }
}
