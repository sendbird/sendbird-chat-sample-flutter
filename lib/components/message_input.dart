import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Function onPressPlus;
  final Function(String) onPressSend;

  MessageInput({this.onPressPlus, this.onPressSend, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final inputController = TextEditingController();
  bool shouldShowSendButton = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10, top: 10),
      // height: 56,
      // constraints: BoxConstraints(minHeight: 56),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 12, right: 8, bottom: 3),
            padding: EdgeInsets.all(4),
            height: 32,
            width: 32,
            child: FloatingActionButton(
              onPressed: widget.onPressPlus,
              child: Image(
                image: AssetImage('assets/iconAdd@3x.png'),
                fit: BoxFit.scaleDown,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: TextField(
                maxLines: 5,
                minLines: 1,
                // textAlignVertical: TextAlignVertical.bottom,
                controller: inputController,
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                    //borderSide: const BorderSide(),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                  // contentPadding: EdgeInsets.only(top: 2),
                ),
                onChanged: (text) {
                  setState(() {
                    shouldShowSendButton = text != '';
                  });
                },
              ),
            ),
          ),
          if (shouldShowSendButton)
            Container(
              margin: EdgeInsets.only(left: 8, right: 12, bottom: 8),
              child: FloatingActionButton(
                onPressed: () {
                  widget.onPressSend(inputController.text);
                  inputController.clear();
                  setState(() {
                    shouldShowSendButton = inputController.text != '';
                  });
                },
                child: Image(
                  image: AssetImage('assets/iconSend@3x.png'),
                  fit: BoxFit.scaleDown,
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              width: 24,
              height: 24,
            )
          else
            SizedBox(width: 16)
        ],
      ),
    );
  }
}
