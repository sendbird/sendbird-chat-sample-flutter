import 'package:app/color.dart';
import 'package:app/components/feature_item.dart';
import 'package:app/components/textfield_item.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/controllers/poll_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/features/poll/poll.dart';
import 'package:sendbird_sdk/features/poll/poll_data.dart';
import 'package:sendbird_sdk/params/poll_params.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreatePollRoute extends StatefulWidget {
  const CreatePollRoute({super.key});

  @override
  State<CreatePollRoute> createState() => _CreatePollRouteState();
}

class _CreatePollRouteState extends State<CreatePollRoute> {
  List<String> optionTextList = [];
  final _authenticationController = Get.find<AuthenticationController>();
  final _pollController = Get.find<PollController>();
  final titleController = TextEditingController();
  final optionController = TextEditingController();
  late SendbirdSdk sendbirdSDK;
  bool isLoading = false;

  @override
  void initState() {
    sendbirdSDK = _authenticationController.sendbirdSdk;

    //Connect to group channel

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text("Create Poll"),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: textfieldItem("Poll Title Text", titleController),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Flexible(
                    child: textfieldItem("Poll Option Text", optionController),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: () {
                      _pollController
                          .addPollOption(optionController.value.text);
                      optionController.clear();
                      Fluttertoast.showToast(
                        msg: "Poll Option Added",
                      );
                      //TODO
                    },
                    icon: const FaIcon(FontAwesomeIcons.squarePlus),
                  ),
                ],
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

                  final params = PollCreateParams(
                      title: titleController.value.text,
                      options: _pollController.pollOption.value);

                  try {
                    final result = await Poll.create(params: params);
                    Fluttertoast.showToast(
                      msg:
                          "Poll Created!\nTitle: ${result.title}\n Options List: ${result.options.length}",
                      toastLength: Toast.LENGTH_LONG,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Poll Failed Creating!\n$e");
                  }

                  //TODO Create Poll
                  setState(() {
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
                            "Create Poll",
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
  }
}
