import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/services/events-controller.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

import 'notifications-home-tab.dart';

class NotificationsMentionsTab extends StatefulWidget {
  final NotificationsHomeTab notifications;
  const NotificationsMentionsTab({Key? key, required this.notifications}) : super(key: key);

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

    EventsController.instance.addEventHandler(
        EventsController.EVENT_NOTIFICATION_MENTIONED,
        HandlerStructure(
            id: "NotificationsMentionsTab",
            handler: (map) {
              mentionsFeedController.resetFeed();
              mentionsFeedController.updateFeeds();
            },
        )
    );

    super.initState();

    widget.notifications.onReload.add(reload);
  }

  void reload(){
    mentionsFeedController.resetFeed();
    mentionsFeedController.updateFeeds();
  }

  @override
  void dispose() {
    super.dispose();
    widget.notifications.onReload.remove(reload);
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
