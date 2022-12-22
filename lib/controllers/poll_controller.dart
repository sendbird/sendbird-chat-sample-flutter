import 'package:get/state_manager.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class PollController extends GetxController {
  Rx<List<String>> pollOption = Rx<List<String>>([]);
  late GroupChannel pollGroupChannel;
  late String testChannelUrl;

  get getTestChannelUrl => testChannelUrl;

  set setTestChannelUrl(testChannelUrl) => this.testChannelUrl = testChannelUrl;

  addPollOption(String option) {
    pollOption.value.add(option);
  }

  clearPollOption() {
    pollOption.value = [];
  }
}
