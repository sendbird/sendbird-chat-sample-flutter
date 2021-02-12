import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:universal_platform/universal_platform.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';
import 'channel_screen.dart';
import 'package:intl/intl.dart';
import '../components/channel_list_item.dart';

class ChannelListScreen extends StatefulWidget {
  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen>
    with ChannelEventHandler {
  SendbirdSdk sdk = SendbirdSdk();
  GroupChannelListQuery query = GroupChannelListQuery();
  User currentUser;
  List<GroupChannel> groupChannels = [];
  bool isLoading = false;

  Future<void> updateGroupChannels() async {
    // this.isLoading = true;

    // List<GroupChannel> newChannels = await getGroupChannels();
    // if (newChannels == this.groupChannels) {
    //   return;
    // }
    // setState(() {
    //   this.isLoading = false;
    //   this.groupChannels = newChannels;
    // });
  }

  Future<List<GroupChannel>> getGroupChannels() async {
    try {
      final query = GroupChannelListQuery()
        // ..includeEmptyChannel = true
        // ..memberStateFilter = MemberStateFilter.joined
        // ..order = GroupChannelListOrder.latestLastMessage
        ..limit = 15;
      return await query.loadNext();
    } catch (e) {
      print('channel_list_view: getGroupChannel: ERROR: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    currentUser = sdk.getCurrentUser();
    sdk.addChannelHandler('unique-key-for-handler', this);
    updateGroupChannels();
  }

  // @override
  // void onUserJoined(GroupChannel channel, User user) {
  //   if (user.userId == SendbirdSdk().getCurrentUser().userId) {
  //     setState(() {
  //       this.groupChannels = [channel, ...groupChannels];
  //     });
  //   }
  // }

  // TODO: channel change handler + other event handlers

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: navigationBar(),
        body: body(context),
      ),
      onWillPop: () async {
        print('disconnect');
        SendbirdSdk().disconnect();
        return true;
      },
    );
  }

  Widget navigationBar() {
    return AppBar(
      leading: BackButton(color: Theme.of(context).primaryColor),
      toolbarHeight: 65,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: Platform.isAndroid == true ? false : true,
      title: Text('Channels', style: TextStyle(color: Colors.black)),
      actions: [
        Container(
          width: 60,
          child: RawMaterialButton(
            padding: EdgeInsets.fromLTRB(0, 18, 0, 18),
            onPressed: () {
              Navigator.pushNamed(context, '/create_channel');
            },
            shape: CircleBorder(),
            child: Image.asset("assets/iconCreate@3x.png"),
          ),
        ),
      ],
      centerTitle: true,
    );
  }

  // build helpers

  Widget body(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: groupChannels.length,
            itemBuilder: (context, index) {
              GroupChannel channel = groupChannels[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: InkWell(
                  child: ChannelListItem(channel),
                  onTap: () {
                    gotoChannel(channel);
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // Sendbird logic

  void gotoChannel(GroupChannel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelScreen(channel: channel),
      ),
    );
  }
}
