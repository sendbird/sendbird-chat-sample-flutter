import 'package:app/components/app_bar.dart';
import 'package:app/components/padding.dart';
import 'package:app/root.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'color.dart';

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                onTap: () {
                  Get.toNamed(
                    '/RootRoute',
                    arguments: Examples.main,
                  );
                },
                leading: const FaIcon(
                  FontAwesomeIcons.solidPaperPlane,
                  color: sendbirdColor,
                ),
                title: const Text(
                  "Main Example",
                  style: TextStyle(
                    color: sendbirdColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                onTap: () {
                  Get.toNamed(
                    '/RootRoute',
                    arguments: Examples.features,
                  );
                },
                leading: const FaIcon(
                  FontAwesomeIcons.gears,
                  color: sendbirdColor,
                ),
                title: const Text(
                  "Features Example",
                  style: TextStyle(
                    color: sendbirdColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
