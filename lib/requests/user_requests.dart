import 'package:sendbird_chat/sendbird_chat.dart';
import 'package:universal_io/io.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:get/get.dart';

Future<void> updateUserInfo(
    {String? nickName, File? file, String? fileUrl}) async {
  late final BaseAuth _authentication = Get.find<AuthenticationController>();
  FileInfo? _file;

  try {
    if (fileUrl != null && fileUrl != '') {
      _file = FileInfo.fromFileUrl(fileUrl: fileUrl);
    }

    await _authentication.updateCurrentInfo(
      nickName: nickName == '' ? null : nickName,
      file: _file,
    );
  } catch (e) {
    rethrow;
  }
}
