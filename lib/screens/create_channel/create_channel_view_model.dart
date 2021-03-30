import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class CreateChannelViewModel with ChangeNotifier {
  List<UserSelection> selections = [];
  final query = ApplicationUserListQuery();
  final ScrollController lstController = ScrollController();

  int get itemCount => query.hasNext && selections.length != 0
      ? selections.length + 1
      : selections.length;

  bool get hasNext => query.hasNext;

  CreateChannelViewModel() {
    lstController.addListener(_scrollListener);
  }

  Future<void> updateUsers() async {
    List<UserSelection> newSelections = await getUsers();
    if (newSelections == this.selections) {
      return null;
    }

    selections =
        selections.isEmpty ? newSelections : selections + newSelections;
    notifyListeners();
  }

  Future<List<UserSelection>> getUsers() async {
    try {
      List<User> users = await query.loadNext();
      return UserSelection.selectedUsersFrom(users);
    } catch (e) {
      print('create_channel_view: getUsers: ERROR: $e');
      return [];
    }
  }

  List<UserSelection> get selectedUsers =>
      selections.where((s) => s.isSelected).toList();

  Future<GroupChannel> createChannel() async {
    try {
      final userIds = this
          .selections
          .where((selection) => selection.isSelected)
          .map((selection) {
        return selection.user.userId;
      }).toList();
      final params = GroupChannelParams()..userIds = userIds;
      final channel = await GroupChannel.createChannel(params);
      return channel;
    } catch (e) {
      print('create_channel_view: createChannel: ERROR: $e');
      throw e;
    }
  }

  _scrollListener() {
    if (lstController.offset >= lstController.position.maxScrollExtent &&
        !lstController.position.outOfRange &&
        !query.loading) {
      updateUsers();
    }
    if (lstController.offset <= lstController.position.minScrollExtent &&
        !lstController.position.outOfRange) {
      //reach bottom
    }
  }
}

class UserSelection {
  bool isSelected = false;
  User user;
  UserSelection(this.user);
  @override
  String toString() {
    return "UserSelection: {isSelected: $isSelected, user: $user}";
  }

  static List<UserSelection> selectedUsersFrom(List<User> users) {
    List<UserSelection> result = [];
    users.forEach((user) {
      result.add(new UserSelection(user));
    });
    return result;
  }
}
