//
// Generated file. Do not edit.
//

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: depend_on_referenced_packages

import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  ImagePickerPlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
