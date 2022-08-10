import 'package:app/basic_examples/basic_example_route.dart';
import 'package:app/basic_examples/create_channel_route.dart';
import 'package:app/basic_examples/groupChannel/group_channel_route.dart';
import 'package:app/basic_examples/openChannel/open_channel_route.dart';
import 'package:app/features_example/features_example_route.dart';
import 'package:app/main_route.dart';
import 'package:app/models/chat_detail_route.dart';
import 'package:app/models/chat_room_route.dart';
import 'package:app/models/profile_route.dart';
import 'package:app/root.dart';
import 'package:get/get.dart';

final List<GetPage> routes = [
  GetPage(name: "/MainRoute", page: () => const MainRoute()),
  GetPage(name: "/RootRoute", page: () => const RootRoute()),
  GetPage(name: "/BasicExampleRoute", page: () => const BasicExampleRoute()),
  GetPage(
      name: "/FeaturesExampleRoute", page: () => const FeaturesExampleRoute()),
  GetPage(name: "/GroupChannelRoute", page: () => const GroupChannelRoute()),
  GetPage(name: "/OpenChannelRoute", page: () => const OpenChannelRoute()),
  GetPage(name: "/ChatRoomRoute", page: () => const ChatRoomRoute()),
  GetPage(name: "/CreateChannelRoute", page: () => const CreateChannelRoute()),
  GetPage(name: "/ChatDetailRoute", page: () => const ChatDetailRoute()),
  GetPage(name: "/ProfileRoute", page: () => const ProfileRoute()),
];
