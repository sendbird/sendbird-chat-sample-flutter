import 'package:app/components/app_bar.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainExampleRoute extends StatefulWidget {
  const MainExampleRoute({Key? key}) : super(key: key);

  @override
  MainExampleRouteState createState() => MainExampleRouteState();
}

class MainExampleRouteState extends State<MainExampleRoute> {
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
                  Get.toNamed('/OpenChannelRoute');
                },
                child: const Text('Open Channel Example'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
