import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-list-item.dart';
import 'package:gigachat/providers/auth.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatObject> _chats = [];

  bool _loading = false;
  void _loadChats(){
    setState(() {
      _loading = true;
    });

    _chats.add(
      ChatObject(
        lastMessage: "Come closer",
      ),
    );

    _chats.add(
      ChatObject(
        lastMessage: "I dont have much time",
      ),
    );

    _chats.add(
      ChatObject(
        lastMessage: "I need to tell yo...",
      ),
    );

    _chats.add(
      ChatObject(
        lastMessage: ".............",
      ),
    );

    Future.delayed(const Duration(seconds: 1));

    setState(() {
      _loading = false;
    });
  }

  void _createDialog(ChatObject e){

    AlertDialog dialog = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          e.pinned ? ListTile(
            title: const Text("Unpin Conversation"),
            onTap: () {
              //TODO
              Navigator.of(context).pop();
            },
          ) : ListTile(
            title: const Text("pin Conversation"),
            onTap: () {
              //TODO
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text("Delete Conversation"),
            onTap: () {
              //TODO
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text("Snooze Conversation"),
            onTap: () {
              //TODO
              Navigator.of(context).pop();
            },
          ),

          e.username != Auth.getInstance(context).getCurrentUser()!.id ? ListTile(
            title: Text("Report ${e.username}"),
            onTap: () {
              //TODO
              Navigator.of(context).pop();
            },
          ) : const SizedBox.shrink(),
        ],
      ),
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  Widget build(BuildContext context) {

    List<ChatObject> pinned = [];
    List<ChatObject> notPinned = [];
    for (var e in _chats) {
      if (e.pinned) {
        pinned.add(e);
      } else {
        notPinned.add(e);
      }
    }

    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Visibility(
              visible: pinned.isNotEmpty,
              child: const Padding(
                key: ValueKey(1),
                padding: EdgeInsets.only(
                  left: 8,
                  top: 20,
                ),
                child: Text(
                  "Pinned conversations",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),

            ...
            pinned.map((e) => ChatListItem(
              object: e,
              longPress: () {
                _createDialog(e);
              },
              press: () {
                //TODO: implement the real chat
                Navigator.pushNamed(context, "/chat" , arguments: {
                  "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage)
                });
              },
            )).toList()
            ,

            Visibility(
              visible: pinned.isNotEmpty && notPinned.isNotEmpty,
              child: const Padding(
                key: ValueKey(1),
                padding: EdgeInsets.only(
                  left: 8,
                  top: 20,
                ),
                child: Text(
                  "All conversations",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),

            ...
            notPinned.map((e) => ChatListItem(
              object: e,
              longPress: () {
                _createDialog(e);
              },
              press: () {
                //TODO: implement the real chat
                Navigator.pushNamed(context, "/chat" , arguments: {
                  "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage)
                });
              },
            )).toList()
            ,
          ],
        ),
      ),
    );
  }
}
