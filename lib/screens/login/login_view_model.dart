import 'package:flutter/material.dart';
import 'package:sendbird_flutter/main.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class LoginViewModel with ChangeNotifier {
  bool isLoading = false;

  LoginViewModel();

  Future<User> login(String userId, String nickname) async {
    if (userId == '') {
      throw Error();
    }

    isLoading = true;
    notifyListeners();

    try {
      // initialize with app id
      sendbird.setLogLevel(LogLevel.none);

      // connect to sendbird server
      final user = await sendbird.connect(userId);
      final name = nickname == '' ? user.userId : nickname;

      // update user nickname and profile url
      await sendbird.updateCurrentUserInfo(nickname: name);
      // await user.createMetaData({'phone': 'value222'});
      // imageInfo: s.ImageInfo.fromUrl(
      //     name: 'my pic',
      //     url: 'image url here',
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
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(
                    color: Theme.of(context).buttonColor,
                    fontWeight: FontWeight.bold),
              ),
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
