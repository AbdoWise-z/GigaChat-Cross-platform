
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
      return "${delta.inMinutes}m";
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
        margin: EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Image.network(object.profileImage,fit: BoxFit.cover,),
      ),
      title: Text(
        object.nickname,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        object.lastMessage,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
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
