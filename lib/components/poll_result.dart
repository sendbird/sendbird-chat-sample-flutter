import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sendbird_chat/sendbird_chat.dart';

class PollResult extends StatelessWidget {
  final String? appBarTitle;
  final String? title;
  final TextStyle? titleTextStyle;
  final Poll poll;
  const PollResult({
    super.key,
    required this.poll,
    this.appBarTitle,
    this.title,
    this.titleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(appBarTitle ?? ""),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            title ?? "",
            style: titleTextStyle ??
                const TextStyle(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 20),
          //* Previous Poll Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: ListTile(
                leading: const FaIcon(FontAwesomeIcons.squarePollVertical),
                title: Text(poll.title),
                subtitle: Row(
                  children: [
                    const Text("Options: "),
                    for (var pollOption in poll.options)
                      Text("(${pollOption.text})  ")
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
