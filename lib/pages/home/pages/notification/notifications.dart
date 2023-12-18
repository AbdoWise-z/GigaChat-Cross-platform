import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/pages/notification/subPages/notificationSetting.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

class Notifications with HomePageTab {
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
    return AppBarTabs(tabs: ["All" , "Verified" , "Mentions"], indicatorSize: TabBarIndicatorSize.label, tabAlignment: TabAlignment.center);
  }

  @override
  String? getTitle(BuildContext context) {
    return null;
  }

  @override
  List<Widget>? getTabsWidgets(BuildContext context,{FeedController? feedController}) {
    return const <Widget>[
      All(),
      Verified(),
      Mentions(),
    ];
  }

  @override
  Widget? getPage(BuildContext context) {
    //if I didn't use tabs .. this will be called instead of getTabsWidgets()
    return Placeholder();
  }

  @override
  bool isAppBarPinned(BuildContext context) {
    return true;
  }

}

class NotificationItem extends StatelessWidget { // item for each notification
  final String avatar;
  final String username;
  final String message;
  final String timeAgo;

  NotificationItem({
    required this.avatar,
    required this.username,
    required this.message,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(avatar),
      ),
      title: Text('$username $message'),
      subtitle: Text('$timeAgo'),
      onTap: () {
        // Handle the notification item tap action
        print('Notification Tapped');
      },
    );
  }
}
class All extends StatelessWidget {
  const All({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: ListView(
            children: [
              NotificationItem(
                avatar: 'assets/giga-chat-logo-dark.png',
                username: 'user1',
                message: 'Liked your tweet',
                timeAgo: '2m ago',
              ),
              NotificationItem(
                avatar: 'assets/giga-chat-logo-dark.png',
                username: 'user2',
                message: 'Retweeted your tweet',
                timeAgo: '5m ago',
              ),
              // Add more NotificationItem widgets for other notifications
            ],
          ),
        ),
      ),
    );;
  }
}
class Verified extends StatelessWidget {
  const Verified({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/done.png',
          height: 150, // Adjust the height as needed
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 40),
        Text(
          'Nothing to see here — yet',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          'Likes, mentions, reposts, and a whole lot more — when it comes from a verified account, you’ll find it here. ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
class Mentions extends StatelessWidget {
  const Mentions({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Text(
          'Nothing to see here — yet',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          'When someone mentions you, you’ll find it here.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
