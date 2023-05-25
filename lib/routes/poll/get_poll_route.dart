import 'dart:async';

import 'package:app/color.dart';
import 'package:app/components/poll_result.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/controllers/poll_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sendbird_chat/sendbird_chat.dart';

class GetPollRoute extends StatefulWidget {
  const GetPollRoute({super.key});

  @override
  State<GetPollRoute> createState() => _GetPollRouteState();
}

class _GetPollRouteState extends State<GetPollRoute> {
  BaseChannel? _channel;
  late String? _channelUrl;

  List<String> optionTextList = [];
  final _authenticationController = Get.find<AuthenticationController>();
  final _pollController = Get.find<PollController>();
  final titleController = TextEditingController();
  final optionController = TextEditingController();
  late SendbirdChat sendbirdSDK;
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

    final params = PollCreateParams(
      title: 'Get Poll Title',
      optionTexts: ['1', '2', '3'],
    );

    //Create Poll
    pollResult = await Poll.create(params);
    print('init poll created');

    //Send Message with Poll
    final mParams =
        UserMessageCreateParams(message: 'test', pollId: pollResult.id);
    _channel!.sendUserMessage(
      mParams,
      handler: (message, error) {
        print("message with poll sent");
        wait.complete();
      },
    );

    //Send message with poll

    await wait.future;

    return _channel;
  }

  Future<Poll> getPoll(int id) async {
    try {
      final pollRetrievalParams = PollRetrievalParams(
        channelUrl: _channel!.channelUrl,
        pollId: pollResult.id,
        channelType: ChannelType.group,
      );

      //Read Poll
      final result = await Poll.get(pollRetrievalParams);
      // logger.i("Successfully Retrieved Poll", result);
      return result;
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
                  title: const Text("Get Poll"),
                ),
                body: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Below Poll will be retrieved with poll_id: ${pollResult.id}",
                      style: const TextStyle(
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

                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            Poll pollGet = await getPoll(pollResult.id);

                            Fluttertoast.showToast(
                              msg: "Poll Retrieved!",
                            );
                            //? Redirect to show Poll Result
                            Get.off(
                              PollResult(
                                poll: pollGet,
                                appBarTitle: "Get Poll",
                                title: "Below Poll has been retrieved!",
                                titleTextStyle: const TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            );
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: "Poll Failed Deleting!\n$e",
                            );
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
                                    "Get Poll",
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
            return const Center(
              child: Text("Failed Retrieving Group Channel List"),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text("Get Poll"),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }));
  }
}
