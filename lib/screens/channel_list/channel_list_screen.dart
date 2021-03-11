import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:sendbird_flutter/screens/channel_list/channel_list_view_model.dart';
// import 'package:universal_platform/universal_platform.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';
import '../channel/channel_screen.dart';
import 'components/channel_list_item.dart';

class ChannelListScreen extends StatefulWidget {
  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen>
    with ChannelEventHandler {
  ChannelListViewModel model = ChannelListViewModel();

  @override
  void initState() {
    super.initState();
    model.loadChannelList();
  }

  /// Update list view with either by overriding channel event handler methods
  /// or use stream (see _bulidStreamBuilder())
  //
  // @override
  // void onChannelChanged(BaseChannel channel) {
  //   final index = groupChannels
  //       .indexWhere((element) => element.channelUrl == channel.channelUrl);

  //   if (index != -1) {
  //     setState(() {
  //       groupChannels[index] = channel;
  //     });
  //   }
  // }

  /// Update chanel list when new message has been arrived
  // @override
  // void onMessageReceived(BaseChannel channel, BaseMessage message) {
  //   final index = groupChannels
  //       .indexWhere((element) => element.channelUrl == channel.channelUrl);

  //   if (index != -1) {
  //     setState(() {
  //       groupChannels[index] = channel;
  //     });
  //   } else {
  //     setState(() {
  //       groupChannels.insert(0, channel);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: navigationBar(),
        body: p.ChangeNotifierProvider<ChannelListViewModel>(
          create: (context) => model,
          child: p.Consumer<ChannelListViewModel>(
            builder: (context, value, child) {
              return _buildList(value);
            },
          ),
        ),
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

  Widget _buildList(ChannelListViewModel model) {
    if (model.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await model.loadChannelList(reload: true);
      },
      child: ListView.builder(
        itemCount: model.groupChannels.length,
        itemBuilder: (context, index) {
          final channel = model.groupChannels[index];
          return _buildStreamBuilder(model, channel);
        },
      ),
    );
  }

  /// Stream builder with channel change stream
  Widget _buildStreamBuilder(ChannelListViewModel model, GroupChannel channel) {
    return StreamBuilder(
      initialData: channel,
      // use channelChangedStream to update channel list item
      // Multiple streams can be combined with using framework such as rxdart
      // and update channe list with multiple streams
      // (message recevies, channel changed, etc)
      stream: model.sdk
          .channelChangedStream()
          .where((c) => c.channelUrl == channel.channelUrl),
      builder: (ctx, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
          child: InkWell(
            child: ChannelListItem(channel),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChannelScreen(channel: channel),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
