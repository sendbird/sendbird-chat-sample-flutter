import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class EmptyRoute extends StatefulWidget {
  const EmptyRoute({super.key});

  @override
  State<EmptyRoute> createState() => _EmptyRouteState();
}

class _EmptyRouteState extends State<EmptyRoute> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("EMPTY ROUTE"),
    );
  }
}
