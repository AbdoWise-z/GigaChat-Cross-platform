import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

class NotificationsMentionsTab extends StatefulWidget {
  const NotificationsMentionsTab({Key? key}) : super(key: key);

  @override
  State<NotificationsMentionsTab> createState() => _NotificationsMentionsTabState();
}

class _NotificationsMentionsTabState extends State<NotificationsMentionsTab> {

  late FeedController mentionsFeedController;
  @override
  void initState() {
    mentionsFeedController = FeedProvider.getInstance(context).getFeedControllerById(
        context: context,
        id: Home.mentionsFeedID,
        providerFunction: ProviderFunction.HOME_PAGE_MENTIONS,
        clearData: false
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BetterFeed(
        removeController: false,
        removeRefreshIndicator: false,
        providerFunction: ProviderFunction.HOME_PAGE_MENTIONS,
        providerResultType: ProviderResultType.TWEET_RESULT,
        feedController: mentionsFeedController,
    );
  }
}
