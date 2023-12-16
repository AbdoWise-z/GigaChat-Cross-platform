import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/chat-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-list-item.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/providers/auth.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ScrollController _controller = ScrollController();
  final List<ChatObject> _chats = [];
  static const int CHATS_PER_PAGE = 25;
  bool _loading = false;
  bool _loadingMore = false;
  Future<void> _loadChats({bool more = true}) async {
    if (more){
      if (_loadingMore){
        return;
      }
    }else {
      if (_loading){
        return;
      }
    }

    if (more){
      _loadingMore = true;
    }else {
      _loading = true;
      _chats.clear();
    }

    _chats.add(ChatObject(
      mongoID: "65746b4d4e28dea620693a10",
      lastMessageSender: "elkapeer",
      lastMessage: "use Osama as a test chat button :)",
      nickname: "Osama Saleh",
      profileImage: "https://storage.googleapis.com/gigachat-img.appspot.com/0c067b23-8b89-440c-987c-b3c2c5929be0-images%20%284%29.jpg?GoogleAccessId=firebase-adminsdk-5avio%40gigachat-img.iam.gserviceaccount.com&Expires=253399795200&Signature=QM1%2BKZUvNVyjC1zMOb8SbI6JyxN%2FgAtT8AQuydlgmKgJ8GX8rnVdV0w5gESg0dX3Epat%2BH3WysswebdqhKiwas4lJqtVMy4kD%2Bv0TFkpBlBa%2Bqg5XJlmKY4Dc%2Fz3cx%2Bl3Vs4YbjBS0jRnn12wuzYtKJHNRzJhB6NZiAskiyCpravO95V2y5asaPnRAR%2FjOXeDCwhou%2FiWeJVNkZC52pdp%2F6mnu2WrmUAjz34%2Fp6YnWV4LC86Z%2FqzBB56GLI%2Fus3xfrdELr%2FM%2Fg%2FzYWhRL7xz6uxH3So8pX%2B4VkWHobenTrXfoeWnNMDi%2BjuZ9mW%2FeS3a4g7eArojOYMfDbgOisSuqA%3D%3D",
    ));

    setState(() {});

    Auth auth = Auth.getInstance(context);

    var k = await Chat.apiGetChats(auth.getCurrentUser()!.auth!, _chats.length ~/ CHATS_PER_PAGE, CHATS_PER_PAGE);

    if (k.data != null){
      _chats.addAll(k.data!);
    }

    setState(() {
      if (more){
        _loadingMore = false;
      }else {
        _loading = false;
      }
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
    _loadChats(more: false);
    _controller.addListener(() {
      if (_controller.offset == _controller.position.maxScrollExtent){
        _loadChats(more: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_loading){
      return const LoadingPage();
    }

    List<ChatObject> pinned = [];
    List<ChatObject> notPinned = [];
    for (var e in _chats) {
      if (e.pinned) {
        pinned.add(e);
      } else {
        notPinned.add(e);
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadChats(more: false);
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
                  _createDialog(e);
                },
                press: () {
                  //TODO: implement the real chat
                  Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
                    "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage, mongoID: e.mongoID)
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
                  Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
                    "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage, mongoID: e.mongoID)
                  });
                },
              )).toList(),

              Visibility(
                visible: _loadingMore,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
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
      ),
    );
  }
}
