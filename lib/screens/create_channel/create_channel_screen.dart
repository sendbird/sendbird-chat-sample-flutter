import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:sendbird_flutter/main.dart';
import 'package:sendbird_flutter/screens/channel/channel_screen.dart';
import 'package:sendbird_flutter/screens/create_channel/create_channel_view_model.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';

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

  AppBar navigationBar() {
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
          onPressed: () {
            model.createChannel().then((channel) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChannelScreen(channelUrl: channel.channelUrl),
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
    return p.ChangeNotifierProvider<CreateChannelViewModel>(
      create: (context) => model,
      child:
          p.Consumer<CreateChannelViewModel>(builder: (context, value, child) {
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.sendbirdSubtitle1OnLight1),
      controlAffinity: ListTileControlAffinity.platform,
      value: sendbird.currentUser?.userId == selection.user.userId ||
          selection.isSelected,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (bool? value) {
        //Display chat view
        setState(() {
          selection.isSelected = !selection.isSelected;
        });
      },
      secondary: selection.user.profileUrl?.isEmpty == true
          ? CircleAvatar(
              child: Text(
              (selection.user.nickname.isEmpty
                      ? selection.user.userId
                      : selection.user.nickname)
                  .substring(0, 1)
                  .toUpperCase(),
            ))
          : CircleAvatar(
              backgroundImage: NetworkImage(selection.user.profileUrl ?? ''),
            ),
    );
  }

  void _buildErrorAlert(Error error) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: new Text("Channel Creation Error: $error"),
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(15)),
          actions: <Widget>[
            new TextButton(
              child: new Text(
                "Ok",
                style: TextStyle(color: Colors.greenAccent),
              ),
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
