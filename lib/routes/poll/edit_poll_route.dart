import 'dart:async';

import 'package:app/color.dart';
import 'package:app/components/poll_result.dart';
import 'package:app/components/textfield_item.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/controllers/poll_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/features/poll/poll.dart';
import 'package:sendbird_sdk/features/poll/poll_data.dart';
import 'package:sendbird_sdk/params/poll_params.dart';
import 'package:sendbird_sdk/params/poll_update_params.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditPollRoute extends StatefulWidget {
  const EditPollRoute({super.key});

  @override
  State<EditPollRoute> createState() => _EditPollRouteState();
}

class _EditPollRouteState extends State<EditPollRoute> {
  BaseChannel? _channel;
  late String? _channelUrl;

  List<String> optionTextList = [];
  final _authenticationController = Get.find<AuthenticationController>();
  final _pollController = Get.find<PollController>();
  final titleController = TextEditingController();
  final optionController = TextEditingController();
  late SendbirdSdk sendbirdSDK;
  bool isLoading = false;
  late Poll pollResult;

  @override
  void initState() {
    sendbirdSDK = _authenticationController.sendbirdSdk;
    _channelUrl = _pollController.testChannelUrl;

    super.initState();
  }

  Future<BaseChannel?> initialSetup({
    bool loadPrevious = false,
    bool isForce = false,
  }) async {
    final wait = Completer();
    _channel ??= await GroupChannel.getChannel(_channelUrl!);

    if (_channel == null) throw Exception("Unable to retrieve group channel");
    _pollController.pollGroupChannel = _channel as GroupChannel;

    final params = PollCreateParams(title: 'poll', options: ['1', '2', '3'])
      ..data = PollData(text: 'polldata');

    //Create Poll
    pollResult = await Poll.create(params: params);
    print('init poll created');

    //Send Message with Poll
    final mParams = UserMessageParams(message: 'test', pollId: pollResult.id);
    _channel!.sendUserMessage(
      mParams,
      onCompleted: (message, error) {
        print("message with poll sent");
        wait.complete();
      },
    );

    //Send message with poll

    await wait.future;

    return _channel;
  }

  Future<Poll> updatePoll(String title) async {
    final pparams = PollUpdateParams(title: title);
    try {
      Poll pollUpdateResult = await _channel!.updatePoll(
        pollId: pollResult.id,
        params: pparams,
      );
      return pollUpdateResult;
    } catch (e) {
      print('Failed Updating Poll');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initialSetup(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return Listener(
              onPointerDown: (_) {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.focusedChild?.unfocus();
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text("Edit Poll"),
                ),
                body: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Below is created example Poll",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    //* Previous Poll Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        child: ListTile(
                          leading:
                              const FaIcon(FontAwesomeIcons.squarePollVertical),
                          title: Text(pollResult.title),
                          subtitle: Row(
                            children: [
                              const Text("Options: "),
                              for (var pollOption in pollResult.options)
                                Text("(${pollOption.text})  ")
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    //* TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: textfieldItem(
                          "Poll Update Title Text", titleController),
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final result =
                                await updatePoll(titleController.value.text);

                            Fluttertoast.showToast(
                              msg:
                                  "Poll Updated!\nUpdated Title: ${result.title}",
                            );
                            //? Redirect to show Poll Result
                            Get.off(
                              PollResult(
                                poll: result,
                                appBarTitle: "Poll Updated",
                                title: "Below Poll has been updated!",
                              ),
                            );
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: "Poll Failed Updating!\n$e");
                          }

                          setState(() {
                            titleController.clear();
                            isLoading = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: sendbirdColor,
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Update Poll",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(
              child: Text("Failed Retrieving Group Channel List"),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text("Edit Poll"),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }));
  }
}
