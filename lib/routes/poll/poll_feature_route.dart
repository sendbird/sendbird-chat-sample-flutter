import 'package:app/components/feature_item.dart';
import 'package:app/controllers/poll_controller.dart';
import 'package:app/routes/poll/create_poll_route.dart';
import 'package:app/routes/poll/delete_poll_route.dart';
import 'package:app/routes/poll/edit_poll_route.dart';
import 'package:app/routes/poll/get_poll_route.dart';
import 'package:app/routes/poll/vote_poll_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import 'edit_poll_option_route.dart';

class PollFeatureRoute extends StatefulWidget {
  const PollFeatureRoute({super.key});

  @override
  State<PollFeatureRoute> createState() => _PollFeatureRouteState();
}

//! REMINDER: Enable Poll Feature in Sendbird Dashboard [Premium Feature]
class _PollFeatureRouteState extends State<PollFeatureRoute> {
  final _pollController = Get.find<PollController>();
  Future<List<GroupChannel>> loadGroupChannelList() async {
    try {
      return await GroupChannelListQuery().loadNext();
    } catch (e) {
      throw Exception([e, 'Error Retrieving Group Channel List']);
    }
  }

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Poll Features"),
        ),
        body: FutureBuilder<List<GroupChannel>>(
          future: loadGroupChannelList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data?[0].channelUrl == null) {
                return const Center(
                  child: Text("Error: No Group Channel Exists in user [test]"),
                );
              }
              // Set Poll Channel Url
              _pollController.testChannelUrl = snapshot.data![0].channelUrl;
              print("Channel List");
              print(_pollController.testChannelUrl);
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    //* Create Poll
                    featureItem(
                        "Create Poll", () => Get.to(const CreatePollRoute())),
                    //* Edit Poll
                    featureItem(
                      "Edit Poll",
                      () => Get.to(
                        const EditPollRoute(),
                      ),
                    ),
                    //* Delete Poll
                    featureItem(
                      "Delete Poll",
                      () => Get.to(
                        const DeletePollRoute(),
                      ),
                    ),
                    //* Get Poll
                    featureItem(
                      "Get Poll",
                      () => Get.to(
                        const GetPollRoute(),
                      ),
                    ),
                    //* Vote Poll
                    featureItem(
                      "Vote Poll",
                      () => Get.to(
                        const VotePollRoute(),
                      ),
                    ),
                    //* Edit Poll Option
                    featureItem(
                      "Edit Poll Option",
                      () => Get.to(
                        const EditPollOptionRoute(),
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Failed Retrieving Group Channel List"),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
