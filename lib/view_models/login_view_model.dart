import 'package:sendbirdsdk/sendbirdsdk.dart';

class LoginViewModel {
  String appId;

  LoginViewModel({this.appId});

  Future<User> login(String userId, String nickname) async {
    if (userId == null || userId == '' || appId == null) {
      throw Error();
    }

    try {
      // initialize with app id
      final sendbird = SendbirdSdk(appId: appId);

      // connect to sendbird server
      final user = await sendbird.connect(userId);
      sendbird.setLogLevel(LogLevel.verbose);
      final name = nickname == '' || nickname == null ? user.userId : nickname;

      // update user nickname and profile url
      await sendbird.updateCurrentUserInfo(
          nickname: name,
          imageInfo: ImageInfo.fromUrl(
              name: 'my pic',
              url: 'https://avatars.githubusercontent.com/u/848531?s=60&v=4',
              mimeType: 'image/jpeg'));

      print('login with user id ' + user.userId + ' nickname ' + user.nickname);
      return user;
    } catch (e) {
      print('login_view.dart: _signInButton: ERROR: $e');
      throw e;
    }
  }
}
