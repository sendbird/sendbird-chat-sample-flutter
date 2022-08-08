import 'package:app/components/app_bar.dart';
import 'package:app/components/padding.dart';
import 'package:app/root.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainRoute extends StatelessWidget {
  const MainRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(),
      body: paddingComponent(
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Get.toNamed(
                  '/RootRoute',
                  arguments: Examples.main,
                );
              },
              child: const Text('Main Example'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Get.toNamed(
                  '/RootRoute',
                  arguments: Examples.features,
                );
              },
              child: const Text('Features Example'),
            ),
          ],
        ),
      ),
    );
  }
}
