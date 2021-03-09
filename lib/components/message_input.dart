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
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          height: 56,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 12, right: 8),
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
                child: Container(
                  height: 36,
                  child: TextField(
                    textAlignVertical: TextAlignVertical.bottom,
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        // width: 0.0 produces a thin "hairline" border
                        borderRadius: BorderRadius.all(Radius.circular(90.0)),
                        borderSide: BorderSide.none,
                        //borderSide: const BorderSide(),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
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
                  margin: EdgeInsets.only(left: 8, right: 12),
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
        ),
      ),
    );
  }
}
