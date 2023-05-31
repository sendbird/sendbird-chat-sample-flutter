// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class GroupChannelInvitePage extends StatefulWidget {
  const GroupChannelInvitePage({Key? key}) : super(key: key);

  @override
  State<GroupChannelInvitePage> createState() => _GroupChannelInvitePageState();
}

class _GroupChannelInvitePageState extends State<GroupChannelInvitePage> {
  final channelUrl = Get.parameters['channel_url']!;
  final textEditingController = TextEditingController();
  late ApplicationUserListQuery query;

  String title = 'Invite Members';
  bool hasNext = false;
  List<User> userList = [];
  List<String> selectedUserIdList = [];
  String userIdFilter = '';
  List<String> memberList = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    userList.clear();

    GroupChannel.getChannel(channelUrl).then((groupChannel) {
      for (final member in groupChannel.members) {
        memberList.add(member.userId);
      }

      query = ApplicationUserListQuery()
        ..userIdsFilter = [userIdFilter]
        ..next().then((users) {
          setState(() {
            for (final user in users) {
              if (!memberList.contains(user.userId)) {
                userList.add(user);
              }
            }
            hasNext = query.hasNext;
          });
        });
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle(title),
        actions: [
          if (selectedUserIdList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () async {
                final groupChannel = await GroupChannel.getChannel(channelUrl);
                await groupChannel.invite(selectedUserIdList);
                Get.back();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          selectedUserIdList.isNotEmpty ? _selectedUserIdBox() : Container(),
          Expanded(child: userList.isNotEmpty ? _list() : Container()),
          hasNext ? _nextButton() : Container(),
          _userIdFilterBox(),
        ],
      ),
    );
  }

  Widget _selectedUserIdBox() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.maxFinite,
            child: Text(
              selectedUserIdList.toString(),
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 12.0, color: Colors.green),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _list() {
    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (BuildContext context, int index) {
        final user = userList[index];

        return GestureDetector(
          child: Column(
            children: [
              ListTile(
                title: Text(user.userId),
                subtitle: Text(
                  user.nickname,
                  style: const TextStyle(fontSize: 12.0),
                ),
                tileColor: selectedUserIdList.any((e) => e == user.userId)
                    ? Colors.purple[100]
                    : null,
                onTap: () {
                  setState(() {
                    if (selectedUserIdList.contains(user.userId)) {
                      selectedUserIdList.remove(user.userId);
                    } else {
                      selectedUserIdList.add(user.userId);
                    }
                  });
                },
                leading: Widgets.imageNetwork(
                    user.profileUrl, 40.0, Icons.account_circle),
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _nextButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_more, size: 16.0),
        color: Colors.white,
        onPressed: () async {
          if (query.hasNext && !query.isLoading) {
            final users = await query.next();
            setState(() {
              for (final user in users) {
                if (user.userId != SendbirdChat.currentUser!.userId) {
                  userList.add(user);
                }
              }
              hasNext = query.hasNext;
            });
          }
        },
      ),
    );
  }

  Widget _userIdFilterBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Widgets.textField(textEditingController, 'User ID'),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              userIdFilter = textEditingController.value.text;
              _initialize();
              textEditingController.clear();
            },
            child: const Text('Find'),
          ),
        ],
      ),
    );
  }
}
