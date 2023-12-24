import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/notification-class.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/pages/notification/notifications-all-tab.dart';
import 'package:gigachat/pages/home/pages/notification/notifications-mentions-tab.dart';
import 'package:gigachat/pages/home/pages/notification/subPages/notificationSetting.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/notifications-provider.dart';
import 'package:gigachat/services/events-controller.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:intl/intl.dart';

class NotificationsHomeTab with HomePageTab {
  @override
  List<AppBarAction> getActions(BuildContext context) {
    return [
      AppBarAction(icon: Icons.settings, onClick: () => {
      // Navigate to the NotificationSettingsPage when the settings icon is pressed
        Navigator.of(context).push(
           MaterialPageRoute(
          builder: (context) => NotificationSettingsPage(),
           ),
          )
      })
    ];
  }

  @override
  AppBarSearch? getSearchBar(BuildContext context) {
    return null;
  }

  @override
  AppBarTabs? getTabs(BuildContext context) {
    return AppBarTabs(tabs: ["All","Mentions"], indicatorSize: TabBarIndicatorSize.label, tabAlignment: TabAlignment.start);
  }

  @override
  String? getTitle(BuildContext context) {
    return null;
  }

  @override
  List<Widget>? getTabsWidgets(BuildContext context,{FeedController? feedController}) {
    return <Widget>[
      NotificationsAllTab(notifications: this,),
      const NotificationsMentionsTab(),
    ];
  }

  @override
  bool isAppBarPinned(BuildContext context) {
    return true;
  }

  bool seen = false;
  int count = -1;
  void _loadCount(BuildContext context) async {
    count = await NotificationsProvider().getUnseenCount(Auth().getCurrentUser()!.auth!);
    if (context.mounted) {
      setHomeState(() {});
    }
  }

  @override
  int getNotificationsCount(BuildContext context) {
    if (seen) {
      return 0;
    }
    return count;
  }

  @override
  void init(BuildContext context) {
    NotificationsProvider().init();
    _loadCount(context);

    EventsController.instance.addEventHandler(EventsController.EVENT_NOTIFICATIONS_CHANGED,
      HandlerStructure(id: "NotificationsProvider",
        handler: (data) {
          _loadCount(context);
        },
      ),
    );
  }

}
