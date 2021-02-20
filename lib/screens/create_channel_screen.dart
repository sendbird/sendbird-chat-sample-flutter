import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

import 'channel_screen.dart';

class CreateChannelScreen extends StatefulWidget {
  @override
  _CreateChannelScreenState createState() => _CreateChannelScreenState();
}

class UserSelection {
  bool isSelected = false;
  User user;
  UserSelection(this.user);
  @override
  String toString() {
    return "UserSelection: {isSelected: $isSelected, user: $user}";
  }

  static List<UserSelection> selectedUsersFrom(List<User> users) {
    List<UserSelection> result = [];
    users.forEach((user) {
      result.add(new UserSelection(user));
    });
    return result;
  }
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  List<UserSelection> selections = [];

  Future<void> updateUsers() async {
    List<UserSelection> newSelections = await getUsers();
    if (newSelections == this.selections) {
      return;
    }
    setState(() {
      this.selections = newSelections;
    });
  }

  Future<List<UserSelection>> getUsers() async {
    try {
      final query = ApplicationUserListQuery();
      List<User> users = await query.loadNext();
      return UserSelection.selectedUsersFrom(users);
    } catch (e) {
      print('create_channel_view: getUsers: ERROR: $e');
      return [];
    }
  }

  Future<GroupChannel> createChannel() async {
    try {
      final userIds = this
          .selections
          .where((selection) => selection.isSelected)
          .map((selection) {
        return selection.user.userId;
      }).toList();
      final params = GroupChannelParams()..userIds = userIds;
      final channel = await GroupChannel.createChannel(params);
      return channel;
    } catch (e) {
      print('create_channel_view: createChannel: ERROR: $e');
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    updateUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: navigationBar(),
      body: body(context),
    );
  }

  Widget navigationBar() {
    return AppBar(
      leading: BackButton(color: Theme.of(context).buttonColor),
      toolbarHeight: 65,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text('Select members', style: TextStyle(color: Colors.black)),
      actions: [
        FlatButton(
          textColor: Theme.of(context).primaryColor,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: EdgeInsets.all(8.0),
          splashColor: Theme.of(context).primaryColor,
          onPressed: () {
            createChannel().then((channel) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChannelScreen(channel: channel),
                ),
              );
            }).catchError((error) {
              _buildErrorAlert(error);
            });
          },
          child: Text(
            "Create",
            style: TextStyle(fontSize: 20.0),
          ),
        )
      ],
      centerTitle: true,
    );
  }

  Widget body(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: selections.length,
            itemBuilder: (context, index) {
              UserSelection selection = selections[index];
              return _buildUserItem(selection);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserItem(UserSelection selection) {
    return CheckboxListTile(
      // tileColor: Colors.white,
      title: Text(
          selection.user.nickname.isEmpty
              ? selection.user.userId
              : selection.user.nickname,
          style: TextStyle(color: Colors.black)),
      controlAffinity: ListTileControlAffinity.platform,
      value: SendbirdSdk().getCurrentUser().userId == selection.user.userId ||
          selection.isSelected,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (bool value) {
        //Display chat view
        setState(() {
          selection.isSelected = !selection.isSelected;
        });
      },
      secondary: selection.user.profileUrl.isEmpty
          ? CircleAvatar(
              child: Text(
              (selection.user.nickname.isEmpty
                      ? selection.user.userId
                      : selection.user.nickname)
                  .substring(0, 1)
                  .toUpperCase(),
            ))
          : CircleAvatar(
              backgroundImage: NetworkImage(selection.user.profileUrl),
            ),
    );
  }

  void _buildErrorAlert(Error error) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Channel Creation Error: $error"),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(15)),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Ok"),
              textColor: Colors.greenAccent,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
