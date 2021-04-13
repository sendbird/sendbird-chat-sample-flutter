import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart' as s;

class LoginViewModel with ChangeNotifier {
  String appId;
  bool isLoading = false;

  LoginViewModel({this.appId});

  Future<s.User> login(String userId, String nickname) async {
    if (userId == null || userId == '' || appId == null) {
      throw Error();
    }

    isLoading = true;
    notifyListeners();

    try {
      // initialize with app id
      final sendbird = s.SendbirdSdk(appId: appId);
      sendbird.setLogLevel(s.LogLevel.none);

      // connect to sendbird server
      final user = await sendbird.connect(userId);
      final name = nickname == '' || nickname == null ? user.userId : nickname;

      // update user nickname and profile url
      await sendbird.updateCurrentUserInfo(nickname: name);
      // imageInfo: s.ImageInfo.fromUrl(
      //     name: 'my pic',
      //     url: 'https://avatars.githubusercontent.com/u/848531?s=60&v=4',
      //     mimeType: 'image/jpeg'));

      isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('login_view.dart: _signInButton: ERROR: $e');
      throw e;
    }
  }

  void showLoginFailAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: RichText(
            textAlign: TextAlign.left,
            softWrap: true,
            text: TextSpan(
              text: 'Login Failed:  ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'Check connectivity and App Id',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(15),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              textColor: Theme.of(context).buttonColor,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
