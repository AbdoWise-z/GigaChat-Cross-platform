
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/notification-class.dart';
import 'package:gigachat/services/events-controller.dart';
import 'package:gigachat/services/notifications-controller.dart';
import 'package:intl/intl.dart';

class NotificationItem extends StatelessWidget { // item for each notification
  final NotificationObject note;

  const NotificationItem({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: !note.seen,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6 , horizontal: 0),
              child: Container(
                width: 5,
                height: 60,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
                ),
              ),
            ),
          ),
        ),

        ListTile(
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
                      note.type == "follow" ? FontAwesomeIcons.solidStar :
                      note.type == "like" ? FontAwesomeIcons.solidHeart :
                      note.type == "reply" ? FontAwesomeIcons.solidComment :
                      note.type == "quote" ? FontAwesomeIcons.quoteLeft :
                      note.type == "retweet" ? FontAwesomeIcons.retweet :
                      note.type == "mention" ? FontAwesomeIcons.solidBell : FontAwesomeIcons.question,

                      color:
                      note.type == "follow" ?  Colors.yellow :
                      note.type == "like" ? Colors.red :
                      note.type == "reply" ?  Colors.blue :
                      note.type == "quote" ? Colors.blueGrey :
                      note.type == "retweet" ? Colors.purple :
                      note.type == "mention" ?  Colors.greenAccent : Colors.purple,
                      size: 18,
                    ),
                  ),
                )
              ],
            ),
          ),
          title: Text(note.description),
          subtitle: Text(DateFormat.yMMMd('en_US').format(note.creationTime)),
          onTap: () {
            EventsController.instance.triggerEvent(EventsController.EVENT_NOTIFICATION_SEEN, {
              "id" : note.id,
            });
            NotificationsController.dispatchNotification(TriggerNotification.fromNotificationsList(note), context);
          },
        ),
      ],
    );
  }
}

