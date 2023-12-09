import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-item.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-list-item.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/message-input-area.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  static const String pageRoute = "/chat";

  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DateFormat titleFormatter = DateFormat('EEEE, MMMM d');
  double _sideButtonTrigger = 150;
  bool _visiable = false;

  User _with = User();
  List<ChatMessageObject> _chat = [];

  final GlobalKey editor = GlobalKey();
  double _editorHeight = 0;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
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
  }

  void _handleSendMessage(ChatMessageObject m){
    // just for testing
    // m = ChatMessageObject(
    //     id: m.id,
    //     text: m.text,
    //     media: m.media,
    //     self: false,
    //     time: m.time,
    //     state: m.state,
    //     replyTo: m.replyTo
    // );

    _handleNewMessage(m);
  }

  void _handleNewMessage(ChatMessageObject m){
    setState(() {
      _chat.add(m);
      if (_controller.offset == _controller.position.maxScrollExtent){
        Future.delayed(Duration(milliseconds: 100) , () {
          _controller.animateTo(_controller.position.maxScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
        });
      }
    });
  }

  void _handleMessageDeleted(ChatMessageObject m){

  }


  @override
  Widget build(BuildContext context) {
    int day = -1;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle
              ),
              child: Image.network(_with.iconLink,fit: BoxFit.cover,),
            ),

            const SizedBox(width: 10,),

            Text(
              _with.name,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {
            //TODO Implement info
          }, icon: Icon(Icons.info_outline)),
        ],
      ),
      body: SafeArea(
        child: Stack(
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

                            ..._chat.map((e) {
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
                                  ChatItem(message: e, onLongPress: (m) {}, onSwipe: (m) {}),
                                ],
                              );
                            }).toList(),

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
              child: Padding(
                key: editor,
                padding: const EdgeInsets.all(8.0),
                child: MessageInputArea(
                  onMessage: (m) {
                    _handleSendMessage(m);
                  },
                  onSizeChange: () {
                    setState(() {
                      _editorHeight = editor.currentContext!.size!.height;
                    });
                  },
                  onOpen: () {
                    Future.delayed(const Duration(milliseconds: 400) , () {
                      _controller.animateTo(_controller.position.maxScrollExtent, duration: Duration(milliseconds: 50 * ((_controller.position.maxScrollExtent - _controller.offset) / 50.0).round()), curve: Curves.fastOutSlowIn);
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
