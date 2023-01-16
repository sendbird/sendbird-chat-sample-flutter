import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:app/components/dialog.dart';
import 'package:app/components/padding.dart';
import 'package:flutter/material.dart';
//? For Mobile Platform
// import 'package:image_picker/image_picker.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:image_picker_web/image_picker_web.dart';
import "dart:html" as html;

class MessageField extends StatefulWidget {
  final TextEditingController controller;
  final BaseChannel channel;
  final VoidCallback onSend;

  const MessageField({
    Key? key,
    required this.controller,
    required this.channel,
    required this.onSend,
  }) : super(key: key);

  @override
  MessageFieldState createState() => MessageFieldState();
}

class MessageFieldState extends State<MessageField> {
  final ImagePickerWeb picker = ImagePickerWeb();
  html.File? file;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    file = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => dialogComponent(
              context,
              title: 'File Upload',
              content: 'Choose type to upload',
              buttonText1: 'Image',
              onTap1: () async {
                try {
                  //? For Mobile Platform
                  // final _file =
                  //     await picker.pickImage(source: ImageSource.gallery);
                  final _file = await ImagePickerWeb.getImageAsFile();
                  if (_file == null) {
                    throw Exception('File not chosen');
                  } else {
                    file = _file;
                  }
                  //? For Mobile Platform
                  // file = File(_file.path);
                } catch (e) {
                  throw Exception('File Message Send Failed');
                }
                widget.controller.clear();
                setState(() {});
              },
              buttonText2: 'Video',
              onTap2: () async {
                try {
                  //? For Mobile Platform
                  // final _file =
                  //     await picker.pickVideo(source: ImageSource.gallery);
                  final _file = await ImagePickerWeb.getVideoAsFile();
                  if (_file == null) {
                    throw Exception('File not chosen');
                  } else {
                    file = _file;
                  }

                  //? For Mobile Platform
                  // file = File(_file.path);
                } catch (e) {
                  throw Exception('File Message Send Failed');
                }
                widget.controller.clear();
                setState(() {});
              },
            ),
            icon: const Icon(Icons.add),
          ),
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 3,
              controller: widget.controller,
              decoration: InputDecoration(
                prefixIcon: file != null ? const Icon(Icons.file_copy) : null,
                suffixIcon: file != null
                    ? IconButton(
                        onPressed: () => {
                              file = null,
                              widget.controller.clear(),
                              setState(() {}),
                            },
                        icon: const Icon(Icons.clear))
                    : null,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (file != null) {
                if (kIsWeb) {
                  final reader = html.FileReader();
                  reader.readAsArrayBuffer(file!);
                  await reader.onLoad.first;
                  //if web send as bytes

                  widget.channel.sendFileMessage(
                    FileMessageParams.withBytes(
                      reader.result as Uint8List,
                      fileExtensionType: file?.type,
                    ),
                    onCompleted: (message, error) => {
                      file = null,
                      widget.controller.clear(),
                      widget.onSend(),
                    },
                  );
                } else {
                  //? For Mobile Platform
                  // widget.channel.sendFileMessage(
                  //   FileMessageParams.withFile(file!),
                  //   onCompleted: (message, error) => {
                  //     file = null,
                  //     widget.controller.clear(),
                  //     widget.onSend(),
                  //   },
                  // );
                }
              } else if (widget.controller.value.text.isNotEmpty) {
                widget.channel.sendUserMessage(
                  UserMessageParams(message: widget.controller.value.text),
                  onCompleted: ((message, error) => {
                        widget.controller.clear(),
                        widget.onSend(),
                      }),
                );
              }
            },
            child: paddingComponent(
              widget: const SizedBox.square(
                dimension: 20,
                child: Icon(Icons.send),
              ),
            ),
          )
        ],
      ),
    );
  }
}
