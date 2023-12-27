import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-list-item.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/chat-provider.dart';
import 'package:provider/provider.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ScrollController _controller = ScrollController();

  bool _loading = false;
  Future<void> _loadChats() async {
    setState(() {
      _loading = true;
    });

    await ChatProvider.instance.reloadChats(Auth().getCurrentUser()!.auth! , notify: false);
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
  }

  @override
  Widget build(BuildContext context) {

    if (_loading){
      return const LoadingPage();
    }


    return Consumer<ChatProvider>(builder: (_ , __ , ___){
      List<ChatObject> pinned = [];
      List<ChatObject> notPinned = [];
      List<ChatObject> _chats = ChatProvider.instance.getCurrentChats();
      for (var e in _chats) {
        if (e.pinned) {
          pinned.add(e);
        } else {
          notPinned.add(e);
        }
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _loadChats();
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: _chats.isEmpty,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 200 , left: 20 , right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No messages yet",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,),
                          ),
                          Text(
                            "search for users to starting messaging!",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

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
                    //_createDialog(e);
                  },
                  press: () async {
                    Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
                      "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage, mongoID: e.mongoID, isFollowed: e.followed, isWantedUserBlocked: e.blocked),
                      "message" : e.lastMessage,
                    });
                  },
                )).toList(),

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
                    //_createDialog(e);
                  },
                  press: () async {
                    Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
                      "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage, mongoID: e.mongoID, isFollowed: e.followed, isWantedUserBlocked: e.blocked),
                      "message" : e.lastMessage,
                    });
                  },
                )).toList(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
