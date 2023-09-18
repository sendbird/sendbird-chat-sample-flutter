import 'dart:async';

import 'package:app/controllers/authentication_controller.dart';
import 'package:app/controllers/poll_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/events/poll_vote_event.dart';
import 'package:sendbird_sdk/features/poll/poll.dart';
import 'package:sendbird_sdk/params/poll_params.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class VotePollRoute extends StatefulWidget {
  const VotePollRoute({super.key});

  @override
  State<VotePollRoute> createState() => _VotePollRouteState();
}

class _VotePollRouteState extends State<VotePollRoute> {
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

    final params = PollCreateParams(
      title: 'What is your favorite animal?',
      options: ['Cat', 'Dog', 'Bird'],
    );

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

  Future<PollVoteEvent> votePoll(int pollId, List<int> pollOptionIds) async {
    try {
      PollVoteEvent poll = await _channel!
          .votePoll(pollId: pollId, pollOptionIds: pollOptionIds);
      return poll;
    } catch (e) {
      print('Failed Voting Poll');
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
                title: const Text("Vote Poll"),
              ),
              body: Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    final int days = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day + 4,
                    )
                        .difference(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ))
                        .inDays;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: FlutterPolls(
                        pollId: pollResult.id.toString(),
                        // hasVoted: hasVoted.value,
                        // userVotedOptionId: userVotedOptionId.value,
                        onVoted:
                            (PollOption pollOption, int newTotalVotes) async {
                          await Future.delayed(const Duration(seconds: 1));

                          /// If HTTP status is success, return true else false
                          return true;
                        },
                        pollEnded: days < 0,
                        pollTitle: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            pollResult.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        pollOptions: List<PollOption>.from(
                          pollResult.options.map(
                            (option) {
                              var a = PollOption(
                                id: option.id.toString(),
                                title: Text(
                                  option.text,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                votes: option.voteCount,
                              );
                              return a;
                            },
                          ),
                        ),
                        votedPercentageTextStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        metaWidget: Row(
                          children: [
                            const SizedBox(width: 6),
                            const Text(
                              '•',
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              days < 0 ? "ended" : "ends $days days",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
              title: const Text("Vote Poll"),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      }),
    );
  }
}
