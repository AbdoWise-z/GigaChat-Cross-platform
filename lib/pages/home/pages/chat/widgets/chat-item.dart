import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/widgets/swipe-to.dart';
import 'package:gigachat/widgets/video-player.dart';
import 'package:intl/intl.dart';

class ChatItem extends StatelessWidget {

  final ChatMessageObject message;
  final ChatMessageObject? replyTo;

  const ChatItem({super.key, required this.message , this.replyTo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        SwipeTo(
          child: ChatMessageContent(
            messageObject: message,
            replyObject: message,
          ),
          onRightSwipe: () {
            print("swipe");
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat('hh:mm a').format(message.time!),
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

class ChatMessageContent extends StatelessWidget {
  final ChatMessageObject messageObject;
  final ChatMessageObject? replyObject;
  const ChatMessageContent({super.key, required this.messageObject , required this.replyObject});

  Widget _getMediaObjectFor(ChatMessageObject object){
    if (object.media == null) {
      return SizedBox.shrink();
    }

    if (object.media!.type == MediaType.VIDEO){
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: VideoPlayerWidget(videoUrl: object.media!.link,),
      );
    }else{
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Image.network(object.media!.link,),
      );
    }
  }

  Widget _getReplyObject(BuildContext context){
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: 8 + 40,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey.shade300,

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              replyObject!.text,
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(

      //fit: StackFit.passthrough,
      //alignment: messageObject.self ? Alignment.centerRight : Alignment.centerLeft,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: messageObject.self ? Alignment.centerRight : Alignment.centerLeft,
          child: _getReplyObject(context),
        ),

        Transform.translate(
          offset: Offset(0, -40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            width: double.infinity,
            alignment: messageObject.self ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              children: [
                _getMediaObjectFor(messageObject),

                SizedBox.square(dimension: messageObject.media == null ? 0 : 5,),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: messageObject.self ? const Radius.circular(20) :  const Radius.circular(6),
                      bottomRight: messageObject.self ? const Radius.circular(6) :  const Radius.circular(20),
                    ),
                    color: messageObject.self ? Colors.blue : Colors.black,
                  ),
                  child: Text(
                    "messageObject.text messageObject.text messageObject.text",
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

