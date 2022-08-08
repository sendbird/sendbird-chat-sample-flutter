import 'dart:io';

import 'package:app/components/app_bar.dart';
import 'package:app/components/dialog.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/requests/user_requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileRoute extends StatefulWidget {
  const ProfileRoute({Key? key}) : super(key: key);

  @override
  ProfileRouteState createState() => ProfileRouteState();
}

class ProfileRouteState extends State<ProfileRoute> {
  late final BaseAuth _authentication = Get.find<AuthenticationController>();
  late final TextEditingController _nameController;
  late final TextEditingController _fileUrlController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _nameController = TextEditingController();
    _fileUrlController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  Widget _nameWidget() {
    if (_authentication.currentUser?.nickname != null) {
      return Text(
        'Hello, ${_authentication.currentUser?.nickname.capitalizeFirst}!',
        style: const TextStyle(fontSize: 24),
      );
    } else {
      return const Text(
        'Hello!',
        style: TextStyle(fontSize: 24),
      );
    }
  }

  Future<void> uploadProfile() async {
    try {
      final profileImage = await _picker.pickImage(source: ImageSource.gallery);
      if (profileImage != null) {
        await updateUserInfo(file: File(profileImage.path));
        printInfo(info: 'User profile image updated');
        if (mounted) {
          dialogComponent(
            context,
            title: 'Profile Image has changed!',
            type: DialogType.oneButton,
          );
        }
        setState(() {});
      }
    } catch (e) {
      printError(info: 'Upload Profile Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarComponent(title: 'Profile', includeLeading: false),
        body: paddingComponent(
          horizontalPadding: 40,
          widget: Column(
            children: [
              const Spacer(),
              _nameWidget(),
              const SizedBox(height: 24),
              _authentication.currentUser?.profileUrl != null &&
                      _authentication.currentUser?.profileUrl != ''
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        _authentication.currentUser!.profileUrl!,
                      ),
                      child: SizedBox.expand(
                        child: IconButton(
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(4),
                          onPressed: () {
                            //TODO
                            // uploadProfile();
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 40,
                      child: IconButton(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(4),
                        onPressed: () {
                          //TODO
                          // uploadProfile();
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ),
              const Spacer(),
              TextField(
                controller: _fileUrlController,
                decoration: const InputDecoration(
                  hintText: 'Profile File Url',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Change Nickname',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  try {
                    await updateUserInfo(
                      nickName: _nameController.value.text,
                      fileUrl: _fileUrlController.value.text,
                    );
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      dialogComponent(
                        context,
                        title: 'User Info has changed',
                        type: DialogType.oneButton,
                      ).then((value) => Navigator.pop(context));
                    }
                  } catch (e) {
                    printError(info: e.toString());
                  }
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () async {
                  try {
                    await _authentication.logout();
                    Get.offAllNamed('/MainRoute');
                  } catch (e) {
                    printError(info: e.toString());
                  }
                },
                child: const Text('Sign Out'),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ));
  }
}
