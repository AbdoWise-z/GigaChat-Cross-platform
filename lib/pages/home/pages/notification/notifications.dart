import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/notification-class.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/pages/notification/subPages/notificationSetting.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/notifications-provider.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:intl/intl.dart';

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
    return AppBarTabs(tabs: ["All"], indicatorSize: TabBarIndicatorSize.label, tabAlignment: TabAlignment.start);
  }

  @override
  String? getTitle(BuildContext context) {
    return null;
  }

  @override
  List<Widget>? getTabsWidgets(BuildContext context,{FeedController? feedController}) {
    return <Widget>[
      All(notifications: this,),
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
    print("Not count $count");
    if (context.mounted) {
      setHomeState(() {
        print("setting home state");
      });
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
    _loadCount(context);
  }

}

class NotificationItem extends StatelessWidget { // item for each notification
  final NotificationObject note;

  const NotificationItem({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 45,
        height: 45,
        child: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(note.img),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 20,
                height: 20,
                child: Icon(
                    note.type == "follow" ? FontAwesomeIcons.star :
                    note.type == "retweet" ? FontAwesomeIcons.retweet :
                    note.type == "like" ? FontAwesomeIcons.heart :
                    note.type == "reply" ? FontAwesomeIcons.comment :
                    note.type == "follow" ? FontAwesomeIcons.star :
                    note.type == "follow" ? FontAwesomeIcons.star :
                    note.type == "follow" ? FontAwesomeIcons.star :
                    note.type == "follow" ? FontAwesomeIcons.star : FontAwesomeIcons.question,

                  color:
                  note.type == "follow" ? Colors.yellow :
                  note.type == "retweet" ?  Colors.blue :
                  note.type == "like" ?  Colors.red :
                  note.type == "reply" ? Colors.green :
                  note.type == "follow" ?  Colors.purple :
                  note.type == "follow" ?  Colors.purple :
                  note.type == "follow" ?  Colors.purple :
                  note.type == "follow" ?  Colors.purple :  Colors.purple,
                ),
              ),
            )
          ],
        ),
      ),
      title: Text(note.description),
      subtitle: Text(DateFormat("yyyy mm dd").format(note.creation_time)),
      onTap: () {
        // Handle the notification item tap action
        print('Notification Tapped');
      },
    );
  }
}

class All extends StatefulWidget {
  final Notifications notifications;
  const All({super.key, required this.notifications});

  @override
  State<All> createState() => _AllState();
}

class _AllState extends State<All> {
  List<NotificationObject> _notes = [];
  void _loadNotes() async {
    _notes = await NotificationsProvider().getAllNotifications(Auth().getCurrentUser()!.auth!);
    setState(() {});
  }

  bool _loading = false;
  bool _canLoadMore = true;
  void _loadMore() async {
    if (_loading || !_canLoadMore) {
      return;
    }
    _loading = true;
    setState(() {

    });

    List<NotificationObject>? list = await NotificationsProvider().getNotifications(Auth().getCurrentUser()!.auth!);
    _notes.addAll(list);

    if (list.isEmpty){
      _canLoadMore = false;
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScrollController controller = Home.getScrollGlobalKey(context)!.currentState!.innerController;
      controller.addListener(() {
        if (controller.position.maxScrollExtent - controller.offset < 100){
          _loadMore();
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _canLoadMore = true;
        _notes = await NotificationsProvider().reloadAll(Auth().getCurrentUser()!.auth!);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            ..._notes.map((e) => NotificationItem(note: e)),
            Visibility(
              visible: _loading,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

