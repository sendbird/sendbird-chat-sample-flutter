import 'package:app/color.dart';
import 'package:app/routes/poll/poll_feature_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeaturesExampleRoute extends StatefulWidget {
  const FeaturesExampleRoute({Key? key}) : super(key: key);

  @override
  FeaturesExampleRouteState createState() => FeaturesExampleRouteState();
}

class FeaturesExampleRouteState extends State<FeaturesExampleRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sendbird Features"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            //* Poll Feature Example Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                onTap: () async {
                  //? Redirect to [PollFeatureRoute]
                  Get.to(const PollFeatureRoute());
                },
                leading: const FaIcon(
                  FontAwesomeIcons.squarePollVertical,
                  color: sendbirdColor,
                ),
                title: const Text(
                  "Poll Feature Example",
                  style: TextStyle(
                    color: sendbirdColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                onTap: () async {
                  //TODO
                },
                leading: const FaIcon(
                  FontAwesomeIcons.gear,
                  color: Colors.grey,
                ),
                title: const Text(
                  "More Feature Examples will be available soon...",
                  style: TextStyle(
                    color: Colors.grey,
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
