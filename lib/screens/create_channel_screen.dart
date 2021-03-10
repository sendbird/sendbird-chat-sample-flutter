import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

import '../view_models/create_channel_view_model.dart';
import 'channel_screen.dart';

class CreateChannelScreen extends StatefulWidget {
  @override
  _CreateChannelScreenState createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final model = CreateChannelViewModel();

  @override
  void initState() {
    super.initState();
    model.updateUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: navigationBar(),
      body: SafeArea(child: body(context)),
    );
  }

  Widget navigationBar() {
    final selectedCountText =
        model.selectedUsers.length == 0 ? '' : model.selectedUsers.length;

    return AppBar(
      leading: BackButton(color: Theme.of(context).buttonColor),
      toolbarHeight: 65,
      elevation: 1,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text('New channel', style: TextStyles.sendbirdH1OnLight1),
      actions: [
        FlatButton(
          textColor: Theme.of(context).primaryColor,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: EdgeInsets.all(8.0),
          splashColor: Theme.of(context).primaryColor,
          onPressed: () {
            model.createChannel().then((channel) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChannelScreen(channel: channel),
                ),
              );
            }).catchError((error) {
              _buildErrorAlert(error);
            });
          },
          child: Text(
            "$selectedCountText Create",
            style: TextStyles.sendbirdButtonPrimary300,
          ),
        )
      ],
      centerTitle: true,
    );
  }

  Widget body(BuildContext context) {
    return ChangeNotifierProvider<CreateChannelViewModel>(
      builder: (context) => model,
      child: Consumer<CreateChannelViewModel>(builder: (context, value, child) {
        return ListView.separated(
          controller: model.lstController,
          itemCount: model.itemCount,
          itemBuilder: (context, index) {
            if (index == model.selections.length && model.hasNext) {
              return Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            UserSelection selection = model.selections[index];
            return _buildUserItem(selection);
          },
          separatorBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.only(left: 70),
                height: 1,
                color: SBColors.onlight_04);
          },
        );
      }),
    );
  }

  Widget _buildUserItem(UserSelection selection) {
    return CheckboxListTile(
      // tileColor: Colors.white,
      title: Text(
          selection.user.nickname.isEmpty
              ? selection.user.userId
              : selection.user.nickname,
          style: TextStyles.sendbirdSubtitle1OnLight1),
      controlAffinity: ListTileControlAffinity.platform,
      value: SendbirdSdk().getCurrentUser().userId == selection.user.userId ||
          selection.isSelected,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (bool value) {
        //Display chat view
        setState(() {
          selection.isSelected = !selection.isSelected;
        });
      },
      secondary: selection.user.profileUrl.isEmpty
          ? CircleAvatar(
              child: Text(
              (selection.user.nickname.isEmpty
                      ? selection.user.userId
                      : selection.user.nickname)
                  .substring(0, 1)
                  .toUpperCase(),
            ))
          : CircleAvatar(
              backgroundImage: NetworkImage(selection.user.profileUrl),
            ),
    );
  }

  void _buildErrorAlert(Error error) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Channel Creation Error: $error"),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(15)),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Ok"),
              textColor: Colors.greenAccent,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
