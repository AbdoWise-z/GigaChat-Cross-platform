import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-item.dart';

class ChatPage extends StatefulWidget {
  static final String pageRoute = "chat";

  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ChatItem(
              message: ChatMessageObject(
                  id: "asfdjs;dbdfg",
                  media: null,
                  replyTo: null,
                  self: true,
                  text: "this is a message",
                  time: DateTime.now(),
                  state: ChatMessageObject.STATE_READ
              ),
            ),

            SizedBox(height: 5,),

            ChatItem(
              message: ChatMessageObject(
                  id: "asfdjs;dbdfg",
                  media: MediaObject(link: "https://cdn.discordapp.com/attachments/1168192198764933280/1180253019934314587/image.png?ex=657cbf47&is=656a4a47&hm=cb58781313b28a105b64fdc4570e2677e62cbc8cea70e422a4a8e4fcb4030a5e&", type: MediaType.IMAGE),
                  replyTo: null,
                  self: true,
                  text: "this is a message and this is a very long message daaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaamn",
                  time: DateTime.now(),
                  state: ChatMessageObject.STATE_READ
              ),
            ),

            SizedBox(height: 5,),

            ChatItem(
              message: ChatMessageObject(
                  id: "asfdjs;dbdfg",
                  media: null,
                  replyTo: null,
                  self: false,
                  text: "this is a message and this is a very long message daaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaamn",
                  time: DateTime.now(),
                  state: ChatMessageObject.STATE_READ
              ),
            ),
          ],
        ),
      ),
    );
  }
}
