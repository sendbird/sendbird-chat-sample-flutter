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
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                labelText: 'User ID',
                errorText: _errormsg == '' ? null : _errormsg,
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () async {
                try {
                  if (_idController.value.text == '' ||
                      _idController.value.text.isEmpty) {
                    throw Exception('ID can NOT be empty');
                  }
                  await _authentication.login(userId: _idController.value.text);

                  switch (widget.examples) {
                    case Examples.main:
                      Get.toNamed('/MainExampleRoute');
                      break;
                    case Examples.features:
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
              },
              child: const Text(
                'Connect',
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
