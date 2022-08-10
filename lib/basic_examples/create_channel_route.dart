import 'package:app/components/app_bar.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/requests/channel_requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class CreateChannelRoute extends StatefulWidget {
  const CreateChannelRoute({Key? key}) : super(key: key);

  @override
  CreateChannelRouteState createState() => CreateChannelRouteState();
}

class CreateChannelRouteState extends State<CreateChannelRoute> {
  final BaseAuth _authentication = Get.find<AuthenticationController>();
  final ChannelType _channelType = Get.arguments[0];
  late final TextEditingController _channelNameController;
  late final TextEditingController _inviteIdController;
  List<String> _inviteIds = [];

  @override
  void initState() {
    _channelNameController = TextEditingController();
    _inviteIdController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    _inviteIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(title: 'Create Channel', includeLeading: false),
      body: paddingComponent(
        widget: Column(
          children: [
            const SizedBox(height: 60),
            if (_inviteIds.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(5),
                ),
                height: 150,
                child: ListView.builder(
                    itemCount: _inviteIds.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          _inviteIds[index],
                        ),
                      );
                    }),
              ),
            const SizedBox(height: 60),
            TextField(
              controller: _channelNameController,
              decoration: const InputDecoration(
                hintText: 'Channel Name',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inviteIdController,
                    decoration: const InputDecoration(
                      hintText: 'Invite UserId',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _inviteIds.add(_inviteIdController.value.text);
                    setState(() {});
                  },
                  child: const Icon(Icons.add),
                )
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () async {
                  var params;
                  switch (_channelType) {
                    case ChannelType.group:
                      params = GroupChannelParams()
                        ..name = _channelNameController.value.text
                        ..operatorUserIds = [
                          _authentication.currentUser!.userId
                        ]
                        ..userIds = _inviteIds;
                      break;
                    case ChannelType.open:
                      // TODO: Handle this case.
                      break;
                  }
                  await createChannel(
                      channelType: _channelType, channelParams: params);
                  //TODO callback to refresh previous page
                  Get.back();
                },
                child: const Text('Create Channel'))
          ],
        ),
      ),
    );
  }
}
