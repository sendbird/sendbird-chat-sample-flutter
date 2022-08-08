import 'package:app/components/app_bar.dart';
import 'package:app/components/dialog.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/requests/channel_requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class GroupChannelRoute extends StatefulWidget {
  const GroupChannelRoute({Key? key}) : super(key: key);

  @override
  GroupChannelRouteState createState() => GroupChannelRouteState();
}

class GroupChannelRouteState extends State<GroupChannelRoute> {
  final BaseAuth _authentication = Get.find<AuthenticationController>();
  late List<GroupChannel> _groupChannelList;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<List<GroupChannel>> loadGroupChannelList() async {
    try {
      return await GroupChannelListQuery().loadNext();
    } catch (e) {
      throw Exception([e, 'Error Retrieving Group Channel List']);
    }
  }

  Widget getGroupChannelIcon(GroupChannel? groupChannel) {
    if (groupChannel != null) {
      if (groupChannel.coverUrl != null && groupChannel.coverUrl == '') {
        return SizedBox.square(child: Image.network(groupChannel.coverUrl!));
      }
    }

    return const Icon(Icons.message);
  }

  Widget _infoButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () {
          Get.toNamed('/ProfileRoute')?.then(
            (_) {
              setState(() {});
            },
          );
        },
        child: const Icon(Icons.person),
      ),
    );
  }

  Future<void> refresh() async {
    await loadGroupChannelList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Get.toNamed('/CreateChannelRoute', arguments: [ChannelType.group])
                ?.then((value) {
          setState(() {});
        }),
        backgroundColor: Colors.purple[800],
        child: const Icon(Icons.add),
      ),
      appBar: appBarComponent(
          title: 'Group Channel Route',
          includeLeading: false,
          actions: [_infoButton()]),
      body: LiquidPullToRefresh(
          onRefresh: () => refresh(), // refresh callback
          child: paddingComponent(
            widget: SingleChildScrollView(
              child: FutureBuilder<List<GroupChannel>>(
                future: loadGroupChannelList(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<GroupChannel>> groupChannelList,
                ) {
                  if (groupChannelList.hasData) {
                    return ListView.builder(
                      itemCount: groupChannelList.data?.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: getGroupChannelIcon(
                              groupChannelList.data?[index]),
                          trailing: GestureDetector(
                            onTap: () => dialogComponent(
                              context,
                              buttonText1: 'Delete',
                              type: DialogType.oneButton,
                              onTap1: () async {
                                await deleteChannel(
                                        channel: groupChannelList.data![index])
                                    .then((value) async {
                                  await loadGroupChannelList();
                                  setState(() {});
                                });
                              },
                            ),
                            child: const Icon(Icons.edit),
                          ),
                          title: Text(
                            groupChannelList.data?[index].name ?? 'No Name',
                          ),
                          subtitle: Text(
                            groupChannelList
                                    .data?[index].lastMessage?.message ??
                                '',
                          ),
                          onTap: () {
                            Get.toNamed(
                              '/ChatRoomRoute',
                              arguments: [ChannelType.group],
                              parameters: {
                                'channelUrl':
                                    groupChannelList.data?[index].channelUrl ??
                                        ''
                              },
                            )?.then((value) {
                              setState(() {});
                            });
                          },
                        );
                      },
                    );
                  } else if (groupChannelList.hasError) {
                    return const Text('Error Retrieving Group Channel');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          )),
    );
  }
}
