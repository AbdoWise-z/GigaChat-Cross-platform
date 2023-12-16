import 'package:flutter/material.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/Follow-Button.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:visibility_detector/visibility_detector.dart';

class UserListViewPage extends StatefulWidget {
  static const pageRoute = "/list-view";
  static const feedID = "USER_LIST_FEED";

  const UserListViewPage({super.key});

  @override
  State<UserListViewPage> createState() => _UserListViewPageState();
}

class _UserListViewPageState extends State<UserListViewPage> {
  late ProviderFunction providerFunction;
  String? pageTitle;
  String? tweetID;
  String? userID;
  late FeedController feedController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String,dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    pageTitle = args["pageTitle"];
    tweetID = args["tweetID"];
    userID = args["userID"];
    providerFunction = args["providerFunction"];
    String userToken = Auth.getInstance(context).getCurrentUser()!.auth!;


    feedController = FeedProvider.getInstance(context).getFeedControllerById(
        context: context,
        id: UserListViewPage.feedID + (userID ?? "") + (tweetID ?? ""),
        providerFunction: providerFunction,
        clearData: true
    );

    feedController.setUserToken(userToken);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            pageTitle ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
      ),

      body: BetterFeed(
          removeController: false,
          removeRefreshIndicator: false,
          providerFunction: providerFunction,
          providerResultType: ProviderResultType.USER_RESULT,
          feedController: feedController,
          tweetID: tweetID,
          userId: userID,
      ),
    );
  }
}


