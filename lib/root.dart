import 'package:app/controllers/authentication_controller.dart';
import 'package:app/features_example/features_example_route.dart';
import 'package:app/login_route.dart';
import 'package:app/main_examples/main_example_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AuthStatus { notSignedIn, signedIn }

enum Examples { main, features }

class RootRoute extends StatefulWidget {
  const RootRoute({Key? key}) : super(key: key);

  @override
  RootRouteState createState() => RootRouteState();
}

class RootRouteState extends State<RootRoute> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  late BaseAuth _authentication;
  late bool _isSigned;
  late Examples _examples;

  @override
  void initState() {
    _authentication = AuthenticationController();
    _isSigned = _authentication.isSigned;
    _authStatus =
        _isSigned == true ? AuthStatus.signedIn : AuthStatus.notSignedIn;
    _examples = Get.arguments as Examples;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _authentication.dispose();
    super.dispose();
  }

  void _signedIn() {
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        return LoginRoute(onSignedIn: _signedIn, examples: _examples);
      case AuthStatus.signedIn:
        switch (_examples) {
          case Examples.main:
            return const MainExampleRoute();
          case Examples.features:
            return const FeaturesExampleRoute();
        }
    }
  }
}
