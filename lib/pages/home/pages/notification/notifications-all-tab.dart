
import 'package:flutter/material.dart';
import 'package:gigachat/api/notification-class.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/pages/notification/notifications-home-tab.dart';
import 'package:gigachat/pages/home/pages/notification/widgets/notification-item.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/notifications-provider.dart';
import 'package:provider/provider.dart';

class NotificationsAllTab extends StatefulWidget {
  final NotificationsHomeTab notifications;
  const NotificationsAllTab({super.key, required this.notifications});

  @override
  State<NotificationsAllTab> createState() => _NotificationsAllTabState();
}

class _NotificationsAllTabState extends State<NotificationsAllTab> {
  void _loadNotes() async {
    setState(() {
      _loading = true;
    });
    await NotificationsProvider().getAllNotifications(Auth().getCurrentUser()!.auth!);
    setState(() {
      _loading = false;
    });
  }

  bool _loading = false;
  void _loadMore() async {
    if (_loading || !NotificationsProvider().canLoadMore()) {
      return;
    }
    _loading = true;
    setState(() {});

    await NotificationsProvider().getNotifications(Auth().getCurrentUser()!.auth!);

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
    return Consumer<NotificationsProvider>(
      builder: (context , _ , __) {
        return RefreshIndicator(
          onRefresh: () async {
            await NotificationsProvider().reloadAll(Auth().getCurrentUser()!.auth!);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...NotificationsProvider().getCurrentNotifications().map((e) => NotificationItem(note: e)),
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
    );
  }
}
