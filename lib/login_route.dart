import 'dart:ui';

import 'package:app/color.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/root.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginRoute extends StatefulWidget {
  final VoidCallback onSignedIn;
  final Examples examples;
  const LoginRoute({Key? key, required this.onSignedIn, required this.examples})
      : super(key: key);

  @override
  LoginRouteState createState() => LoginRouteState();
}

class LoginRouteState extends State<LoginRoute> {
  final BaseAuth _authentication = Get.find<AuthenticationController>();
  late TextEditingController _idController;
  String _errormsg = '';
  bool isLoading = false;

  @override
  void initState() {
    _idController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Route'),
      ),
      body: paddingComponent(
        widget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            const Center(
              child: Text(
                "Please Enter ANY UserID to connect to Sendbird ",
                style: TextStyle(
                  color: sendbirdColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              cursorColor: sendbirdColor,
              controller: _idController,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                labelText: 'User ID',
                errorText: _errormsg == '' ? null : _errormsg,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  if (_idController.value.text == '' ||
                      _idController.value.text.isEmpty) {
                    throw Exception('ID can NOT be empty');
                  }

                  switch (widget.examples) {
                    case Examples.main:
                      await _authentication.login(
                          userId: _idController.value.text);
                      Get.toNamed('/BasicExampleRoute');
                      break;
                    case Examples.features:
                      await _authentication.login(userId: "test");
                      Get.toNamed('/FeaturesExampleRoute');
                      break;
                  }
                } on Exception catch (e) {
                  setState(() {
                    _errormsg = e.toString();
                  });
                } catch (e) {
                  _errormsg = 'Unknown Error: $e';
                }
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
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
