import 'package:app/components/app_bar.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BasicExampleRoute extends StatefulWidget {
  const BasicExampleRoute({Key? key}) : super(key: key);

  @override
  BasicExampleRouteState createState() => BasicExampleRouteState();
}

class BasicExampleRouteState extends State<BasicExampleRoute> {
  final BaseAuth _authentication = Get.find<AuthenticationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(title: 'Main Example Page'),
      body: SingleChildScrollView(
        child: paddingComponent(
          widget: Column(
            children: [
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.toNamed('/GroupChannelRoute');
                },
                child: const Text('Group Channel Example'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  //TODO Unimplemented
                  // Get.toNamed('/OpenChannelRoute');
                },
                child: const Text(
                  'Open Channel Example',
                  style: TextStyle(color: Colors.black26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
