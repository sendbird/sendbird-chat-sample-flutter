import 'dart:io';
import 'package:app/controllers/authentication_controller.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/core/models/file_info.dart';

Future<void> updateUserInfo(
    {String? nickName, File? file, String? fileUrl}) async {
  late final BaseAuth _authentication = Get.find<AuthenticationController>();
  FileInfo? _file;

  try {
    if (fileUrl != null && fileUrl != '') {
      _file = FileInfo.fromUrl(url: fileUrl);
    }

    await _authentication.updateCurrentInfo(
      nickName: nickName == '' ? null : nickName,
      file: _file,
    );
  } catch (e) {
    rethrow;
  }
}
