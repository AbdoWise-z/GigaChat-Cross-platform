
import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:intl/intl.dart';

class ChatListItem extends StatelessWidget {
  final ChatObject object;
  final void Function() longPress;
  final void Function() press;
  const ChatListItem({super.key , required this.object, required this.longPress, required this.press});

  String _time(){
    DateTime now = DateTime.now();
    Duration delta = now.difference(object.time!);
    if (delta.inDays > 1){
      return DateFormat("dd MMM").format(object.time!);
    }
    if (delta.inHours == 0){
      if (delta.inMinutes < 5){
        return "just now";
      }
      return "${delta.inMinutes} m";
    }
    return "${delta.inHours}h";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: 0,
      contentPadding: EdgeInsets.zero,
      onLongPress: longPress,
      onTap: press,
      leading: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(object.profileImage,fit: BoxFit.cover,),
            ),
            Visibility(
              visible: !object.lastMessage!.seen,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 4,
                    ),
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        object.nickname,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: object.lastMessage!.self,
            child: const Text(
              "You : ",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              object.lastMessage!.text ?? "[Sent Media]",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Text(
          _time(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey
          ),
        ),
      ),
    );
  }
}
