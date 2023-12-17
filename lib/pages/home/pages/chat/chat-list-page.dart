import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/chat-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-list-item.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/web-socks-provider.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ScrollController _controller = ScrollController();
  final List<ChatObject> _chats = [];
  static const int CHATS_PER_PAGE = 25;
  int page = 1;
  bool _loading = false;
  bool _loadingMore = false;
  bool _canLoadMore = true;
  Future<void> _loadChats({bool more = true}) async {
    if (_loadingMore || _loading){
      return;
    }

    if (more){
      if (_canLoadMore) {
        _loadingMore = true;
      }else{
        return;
      }
    }else {
      _loading = true;
      _canLoadMore = true;
      _chats.clear();
    }

    setState(() {});

    Auth auth = Auth.getInstance(context);

    var k = await Chat.apiGetChats(auth.getCurrentUser()!.auth!, page, CHATS_PER_PAGE);

    if (k.data != null){
      if (k.data!.isEmpty){
        _canLoadMore = false;
      }
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
      if (_controller.offset >= _controller.position.maxScrollExtent - 200){
        _loadChats(more: true);
      }
    });

    WebSocketsProvider.getInstance(context).getStream<Map<String,dynamic>>("receive_message").stream.listen((event) {
      var data = event;
      String id = data["chat_ID"];
      print("CHAT_LIST_PAGE : $data");
      for (ChatObject k in _chats){
        if (k.mongoID == id){
          ChatMessageObject obj = ChatMessageObject();
          obj.fromMap(data);
          k.lastMessage = obj.text ?? "Sent Media";
          k.time = obj.time;
          k.lastMessageSeen = false; //TODO: fix this later
          k.lastMessageSender = obj.self ? Auth.getInstance(context).getCurrentUser()!.mongoID! : k.mongoID;
          setState(() {

          });
          break;
        }
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
                  //_createDialog(e);
                },
                press: () async {
                  var result = await Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
                    "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage, mongoID: e.mongoID, isFollowed: e.followed, isBlocked: e.blocked)
                  }) as Map;
                  setState(() {
                    User u = result["user"];
                    e.blocked = u.isBlocked!;
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
                  //_createDialog(e);
                },
                press: () async {
                  var result = await Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
                    "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage, mongoID: e.mongoID, isFollowed: e.followed, isBlocked: e.blocked)
                  }) as Map;
                  setState(() {
                    User u = result["user"];
                    e.blocked = u.isBlocked!;
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
