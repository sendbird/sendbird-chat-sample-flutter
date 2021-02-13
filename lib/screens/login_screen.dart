import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart' as sb;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final appIdController =
      TextEditingController(text: "D56438AE-B4DB-4DC9-B440-E032D7B35CEB");
  final userIdController = TextEditingController();
  final nicknameController = TextEditingController();
  bool enableSignInButton = false;

  bool _shouldEnableSignInButton() {
    if (appIdController.text == null || appIdController.text == "") {
      return false;
    }
    if (userIdController.text == null || userIdController.text == "") {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 100),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              child: Image(
                image: AssetImage('assets/logoSendbird@3x.png'),
                fit: BoxFit.scaleDown,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sendbird Sample',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 40),
            _buildAppIdField(),
            SizedBox(height: 10),
            _buildUserIdField(),
            SizedBox(height: 10),
            _buildNicknameField(),
            SizedBox(height: 30),
            FractionallySizedBox(
              widthFactor: 1,
              child: _signInButton(context, enableSignInButton),
            )
          ],
        ),
      ),
    );
  }

  // build helpers

  Widget _buildAppIdField() {
    return TextField(
      controller: appIdController,
      onChanged: (value) {
        setState(() {
          enableSignInButton = _shouldEnableSignInButton();
        });
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: 'App Id',
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: IconButton(
          onPressed: () {
            appIdController.clear();
          },
          icon: Icon(Icons.clear),
        ),
      ),
    );
  }

  Widget _buildUserIdField() {
    return TextField(
      controller: userIdController,
      onChanged: (value) {
        setState(() {
          enableSignInButton = _shouldEnableSignInButton();
        });
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: 'User Id',
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: IconButton(
          onPressed: () {
            userIdController.clear();
          },
          icon: Icon(Icons.clear),
        ),
      ),
    );
  }

  Widget _buildNicknameField() {
    return TextField(
      controller: nicknameController,
      onChanged: (value) {
        setState(() {
          enableSignInButton = _shouldEnableSignInButton();
        });
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: 'Nick name',
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: IconButton(
          onPressed: () {
            userIdController.clear();
          },
          icon: Icon(Icons.clear),
        ),
      ),
    );
  }

  Widget _signInButton(BuildContext context, bool enabled) {
    return FlatButton(
      height: 50,
      color: enabled ? Theme.of(context).buttonColor : Colors.grey,
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      onPressed: !enabled ? null : () async => initAndLoginSendbird(context),
      child: Text(
        "Sign In",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }

  void _showLoginFailAlert(BuildContext context) {
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

  // sendbird logic

  void initAndLoginSendbird(BuildContext context) async {
    try {
      // initialize with app id
      final sendbird = sb.SendbirdSdk(appId: appIdController.text);

      // connect to sendbird server
      final user = await sendbird.connect(userIdController.text);

      final nickname = nicknameController.text.isEmpty
          ? user.userId
          : nicknameController.text;

      // update user nickname and profile url
      await sendbird.updateCurrentUserInfo(
          nickname: nickname,
          imageInfo: sb.ImageInfo.fromUrl(
            name: 'my pic',
            url: 'https://avatars.githubusercontent.com/u/848531?s=60&v=4',
          ));

      print('login with user id ' + user.userId + ' nickname ' + user.nickname);
      Navigator.pushNamed(context, '/channel_list');
    } catch (e) {
      print('login_view.dart: _signInButton: ERROR: $e');
      _showLoginFailAlert(context);
    }
  }
}
