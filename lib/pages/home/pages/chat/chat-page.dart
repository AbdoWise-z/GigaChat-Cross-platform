import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/chat-requests.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/media-requests.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/home/pages/chat/chat-info-page.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-item.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-list-item.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/message-input-area.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/profile/profile-image-view.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/chat-provider.dart';
import 'package:gigachat/providers/web-socks-provider.dart';
import 'package:gigachat/services/events-controller.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/Follow-Button.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  static const String pageRoute = "/chat";

  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final double _sideButtonTrigger   = 150;
  final double _loadMessagesTrigger = 300;
  bool _visiable = false;
  late final StreamSocket _chatSocket;
  bool _ready = false;
  late User _with;
  final List<ChatMessageObject> _chat = [];
  late final Uuid uuid;

  final GlobalKey editor = GlobalKey();
  final GlobalKey chatList = GlobalKey();
  double _editorHeight = 0;
  final RetainableScrollController _controller = RetainableScrollController();

  bool _canLoadUp = true;
  bool _canLoadDown = true;
  bool _loadingUp = false;
  bool _loadingDown = false;

  void _loadMessages({down = false}) async {
    if (_loadingUp || _loadingDown) {
      return;
    }
    if (down){
      if (!_canLoadDown){
        return;
      }
      _loadingDown = true;
    }else{
      if (!_canLoadUp){
        return;
      }
      _loadingUp = true;
    }


    setState(() {});

    if (down){
      var res = await ChatProvider.instance.getMessagesAfter(
        Auth.getInstance(context).getCurrentUser()!.auth!,
        _with.mongoID!,
        _chat.last.time!,
      );
      if (res.isEmpty){
        _canLoadDown = false;
      }
      setState(() {
        _loadingDown = false;
        //_controller.retainOffset();
        _chat.addAll(res);
        if (_canLoadUp && _controller.offset - _loadMessagesTrigger <= 0){
          Future.delayed(Duration.zero , () {
            _loadMessages(down: false);
          });
        }
      });
    } else {
      var res = await ChatProvider.instance.getMessagesBefore(
        Auth.getInstance(context).getCurrentUser()!.auth!,
        _with.mongoID!,
        _chat.first.time!,
      );

      if (res.isEmpty){
        _canLoadUp = false;
      }

      setState(() {
        _loadingUp = false;
        _controller.retainOffset();
        _chat.insertAll(0 , res);
        if (_canLoadDown && _controller.position.maxScrollExtent - _controller.offset <= _loadMessagesTrigger){
          Future.delayed(Duration.zero , () {
            _loadMessages(down: true);
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      //message load
      if (_controller.offset - _loadMessagesTrigger <= 0){
        _loadMessages(down: false);
      }

      if (_controller.position.maxScrollExtent - _controller.offset <= _loadMessagesTrigger){
        _loadMessages(down: true);
      }

      //down button trigger
      if (_controller.position.maxScrollExtent - _controller.offset > _sideButtonTrigger){
        if (!_visiable){
          setState(() {
            _visiable = true;
          });
        }
      }else{
        if (_visiable){
          setState(() {
            _visiable = false;
          });
        }
      }
    });

    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_BLOCK,
        HandlerStructure(id: "chat-page",
          handler: (data) {
            if (_with.id == data["username"]){
              _with.isBlocked = true;
            }
          },
        )
    );

    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_FOLLOW,
        HandlerStructure(id: "chat-page",
          handler: (data) {
            if (_with.id == data["username"]){
              _with.isFollowed = true;
            }
          },
        )
    );
    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_UNFOLLOW,
        HandlerStructure(id: "chat-page",
          handler: (data) {
            if (_with.id == data["username"]){
              _with.isFollowed = false;
            }
          },
        )
    );

    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_UNBLOCK,
        HandlerStructure(id: "chat-page",
          handler: (data) {
            if (_with.id == data["username"]){
              _with.isBlocked = false;
            }
          },
        )
    );

    _chatSocket = WebSocketsProvider.getInstance(context).getStream<Map<String,dynamic>>("receive_message");
    uuid = const Uuid();
    _ready = false;

    WebSocketsProvider.getInstance(context).getStream<Map<String,dynamic>>("failed_to_send_message").stream.listen((ev) {
      print("Error : $ev");
      String error = ev["error"];
      if (error.contains("blocked")){ //either you blocked this user or the user blocked you
        String uuid = ev["id"];
        EventsController.instance.triggerEvent(
          EventsController.EVENT_USER_BLOCK_ME,
          {
            "username": _with.id,
          },
        );
        _chat.removeWhere((element) => element.uuid == uuid); //remove that message
        setState(() {
          _with.isBlocked = true;
        });
      }
    });

    _chatSocket.stream.listen((event) {
      var data = event;
      if (data["chat_ID"] == _with.mongoID) {
        print("chat-page : $data");
        ChatMessageObject obj = ChatMessageObject();
        obj.fromMap(data);
        _handleNewMessage(obj);
        EventsController.instance.triggerEvent(EventsController.EVENT_CHAT_MESSAGE_READ, {
          "mongoID" : _with.mongoID,
        });
      }
    });
  }

  Future<bool> sendMessage(ChatMessageObject m) async {
    User current = Auth.getInstance(context).getCurrentUser()!;
    WebSocketsProvider ws = WebSocketsProvider();
    if (m.media != null){
      //if we have a media, we first try to upload it..
      ApiResponse<List> link = await Media.uploadMedia(current.auth! , [
        UploadFile(path: m.media!.link , type: m.media!.type == MediaType.IMAGE ? "image" : "video" , subtype: m.media!.type == MediaType.IMAGE ? "png" : "mp4")
      ]);
      if (link.data == null || link.data!.isEmpty){
        return false;
      }
      m.media = MediaObject(link: link.data![0], type: m.media!.type);
    }
    var data = m.toMap(current.mongoID!, _with.mongoID!);
    ws.send("send_message" , data);
    return true;
  }

  void _handleSendMessage(ChatMessageObject m) async {
    m.uuid = uuid.v4();
    m.state = ChatMessageObject.STATE_SENDING;
    _handleNewMessage(m); //mark as sending and send
    if (! await sendMessage(m)){ //failed
      _handleMessageFailed(m);
    }
  }

  void _handleNewMessage(ChatMessageObject m){
    if (m.self){
      if (m.state == ChatMessageObject.STATE_SENDING){
        _chat.add(m);
      } else if (m.state == ChatMessageObject.STATE_SENT){
        int index = _chat.lastIndexWhere((element) => element.uuid == m.uuid);
        if (index == -1){ //didn't find this message (account is open on another phone ?)
          _chat.add(m);
        }else{
          _chat[index].state = ChatMessageObject.STATE_SENT;
          _chat[index].time = m.time; //TODO: fix server time ?
        }
      }
    }else{
      _chat.add(m);
    }

    if (chatList.currentState != null) {
      chatList.currentState!.setState(() {
        // update the chat list builder state to make it re-build
      });
    }

    if (_controller.hasClients && _controller.offset >= _controller.position.maxScrollExtent - 20){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.animateTo(_controller.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
      });
    }

    // setState(() {
    //
    // });
  }

  void _handleMessageDeleted(String uuid){

  }

  void _handleMessageFailed(ChatMessageObject m){
    int index = _chat.lastIndexWhere((element) => element.uuid == m.uuid);
    if (index == -1){ //didn't find this message (account is open on another phone ?)
      //_chat.add(m); should never happen
    }else{
      _chat[index].state = ChatMessageObject.STATE_FAILED;
    }
    chatList.currentState!.setState(() {
      // update the chat list builder state to make it re-build
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!_ready){
      _ready = true;
      var args = ModalRoute.of(context)!.settings.arguments! as Map;
      _with = args["user"];

      _chat.add(args["message"]);

      //load the messages
      _loadMessages(down: false);
    }

    if (_with.isBlocked!){
      _editorHeight = 50;
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context , {"user" : _with});
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Row(
                children: [

                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => UserProfile(username: _with.id, isCurrUser: false)));
                    },
                    icon: Container(
                      width: 40,
                      height: 40,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            _with.iconLink,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                        border: Border.all(
                          width: 0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10,),

                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(context: context, builder: (_) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 10,),

                                Text(
                                  _with.name,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                  ),
                                ),

                                const SizedBox(height: 10,),

                                ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          _with.iconLink,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                                      border: Border.all(
                                        width: 0,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    _with.name,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "@${_with.id}",
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: Visibility(
                                    visible: !_with.isBlocked!,
                                    child: FollowButton(
                                      isFollowed: _with.isFollowed!,
                                      callBack: (b) {
                                        setState(() {
                                          _with.isFollowed = b;
                                        });
                                      },
                                      username: _with.id,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                    },
                    child: Text(
                      _with.name,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  )
                ],
              ),
              actions: [
                IconButton(onPressed: () async {
                  var result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatInfoPage(_with)));
                  _with = result["user"];
                  setState(() {

                  });
                }, icon: const Icon(Icons.info_outline)),
              ],
            ),
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Expanded(
                        child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            controller: _controller,
                            child: Column(
                              //chat
                              children: [

                                //Header
                                Visibility(
                                  visible: _loadingUp,
                                  child: const Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: SizedBox(width: 25,height: 25,child: CircularProgressIndicator(),),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: !_canLoadUp,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle
                                        ),
                                        child: Image.network(_with.iconLink,fit: BoxFit.cover,),
                                      ),

                                      Text(
                                        _with.name,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 16,
                                        ),
                                      ),

                                      Text(
                                        _with.id,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 10,),
                                      Text(
                                        "${_with.followers} Followers",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 20,),

                                      const Divider(
                                        thickness: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                //Messages area
                                ChatColumn(
                                  key: chatList,
                                  chat: _chat,
                                ),

                                Visibility(
                                  visible: _loadingDown,
                                  child: const Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: SizedBox(width: 25,height: 25,child: CircularProgressIndicator(),),
                                      )
                                    ],
                                  ),
                                ),

                                //Input padding
                                SizedBox(
                                  height: _editorHeight,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: _visiable ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      offset: Offset(-20, -_editorHeight),
                      child: Material(
                        clipBehavior: Clip.antiAlias,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_downward_outlined),
                          onPressed: () {
                            _controller.animateTo(_controller.position.maxScrollExtent, duration: Duration(milliseconds: 50 * ((_controller.position.maxScrollExtent - _controller.offset) / 50.0).round()), curve: Curves.fastOutSlowIn);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _with.isBlocked! ? Container(
                    width: double.infinity,
                    height: 50,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Divider(
                          height: 1,
                          thickness: 0.8,
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "You can no longer send Direct messages to this person.",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      :
                  Padding(
                    key: editor,
                    padding: const EdgeInsets.all(8.0),
                    child: MessageInputArea(
                      onMessage: (m) {
                        _handleSendMessage(m);
                      },
                      onSizeChange: () {
                        setState(() {
                          if (editor.currentContext != null) {
                            _editorHeight = editor.currentContext!.size!.height;
                          }
                        });
                      },
                      onOpen: () {
                        Future.delayed(const Duration(milliseconds: 600) , () {
                          _controller.animateTo(_controller.position.maxScrollExtent, duration: Duration(milliseconds: max(50 * ((_controller.position.maxScrollExtent - _controller.offset) / 50.0).round(),0) + 1), curve: Curves.fastOutSlowIn);
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatColumn extends StatefulWidget {
  final List<ChatMessageObject> chat;
  const ChatColumn({super.key , required this.chat});

  @override
  State<ChatColumn> createState() => _ChatColumnState();
}

class _ChatColumnState extends State<ChatColumn> {
  final DateFormat titleFormatter = DateFormat('EEEE, MMMM d');

  @override
  Widget build(BuildContext context) {
    int day = -1;
    return Column(
      children: [
        ...widget.chat.map((e) {
          String? title;
          var time = e.time!;
          if (day != time.day + time.month * 40){
            title =  titleFormatter.format(time);
            day = time.day + time.month * 40;
          }
          return Column(
            children: [
              (title != null) ? Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(title , style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                ),
              ) : const SizedBox.shrink(),
              ChatItem(message: e,
                onLongPress: (m) {

                },
                onPress: (m) async {
                  if (m.state == ChatMessageObject.STATE_FAILED){ //on failed , resend this thing
                    ChatPageState pageState = context.findAncestorStateOfType<ChatPageState>()!;
                    m.state = ChatMessageObject.STATE_SENDING;
                    pageState.chatList.currentState!.setState(() {});
                    if (! await pageState.sendMessage(m)){ //failed
                      m.state = ChatMessageObject.STATE_FAILED;
                      pageState.chatList.currentState!.setState(() {});
                    }
                  }
                },
                onSwipe: (m) {},
                onImagePress: (m) {
                  if (m.media!.type == MediaType.IMAGE) {
                    Navigator.push(context, MaterialPageRoute(builder: (c) {
                      return ProfileImageView(
                          isProfileAvatar: false,
                          imageUrl: m.media!.link,
                          isCurrUser: false
                      );
                    }));
                  }
                },
                onImageLongPress: (m) {

                },
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}


class RetainableScrollController extends ScrollController {
  RetainableScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  @override
  ScrollPosition createScrollPosition(
      ScrollPhysics physics,
      ScrollContext context,
      ScrollPosition? oldPosition,
      ) {
    return RetainableScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }

  void retainOffset() {
    position.retainOffset();
  }


  @override
  RetainableScrollPosition get position =>
      super.position as RetainableScrollPosition;
}

class RetainableScrollPosition extends ScrollPositionWithSingleContext {
  RetainableScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels = 0.0,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  double? _oldPixels;
  double? _oldMaxScrollExtent;

  bool get shouldRestoreRetainedOffset =>
      _oldMaxScrollExtent != null && _oldPixels != null;

  void retainOffset() {
    if (!hasPixels) return;
    _oldPixels = pixels;
    _oldMaxScrollExtent = maxScrollExtent;
    print("_oldPixels: $_oldPixels , _oldMaxScrollExtent: $_oldMaxScrollExtent");
  }

  /// when the viewport layouts its children, it would invoke [applyContentDimensions] to
  /// update the [minScrollExtent] and [maxScrollExtent].
  /// When it happens, [shouldRestoreRetainedOffset] would determine if correcting the current [pixels],
  /// so that the final scroll offset is matched to the previous items' scroll offsets.
  /// Therefore, avoiding scrolling down/up when the new item is inserted into the first index of the list.
  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    final applied = super.applyContentDimensions(minScrollExtent, maxScrollExtent);

    bool isPixelsCorrected = false;

    if (shouldRestoreRetainedOffset) {
      final diff = maxScrollExtent - _oldMaxScrollExtent!;
      if (_oldPixels! >= minScrollExtent && diff > 0) {
        correctPixels(pixels + diff);
        isPixelsCorrected = true;
      }
      _oldMaxScrollExtent = null;
      _oldPixels = null;
    }

    return applied && !isPixelsCorrected;
  }
}
