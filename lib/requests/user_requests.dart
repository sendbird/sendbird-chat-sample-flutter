import 'package:mime/mime.dart';
import 'package:universal_io/io.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/core/models/file_info.dart';
import 'package:path/path.dart';

Future<void> updateUserInfo(
    {String? nickName, File? file, String? fileUrl}) async {
  late final BaseAuth authentication = Get.find<AuthenticationController>();
  FileInfo? fileInfo;

  try {
    if (fileUrl != null && fileUrl != '') {
      fileInfo = FileInfo.fromUrl(url: fileUrl);
    } else if (file != null) {
      fileInfo = FileInfo.fromData(
        name: basename(file.path),
        file: file,
        mimeType: lookupMimeType(file.path),
      );
    }

    await authentication.updateCurrentInfo(
      nickName: nickName == '' ? null : nickName,
      file: fileInfo,
    );
  } catch (e) {
    rethrow;
  }
}
