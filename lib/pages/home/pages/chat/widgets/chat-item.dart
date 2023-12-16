import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/widgets/swipe-to.dart';
import 'package:gigachat/widgets/video-player.dart';
import 'package:intl/intl.dart';

class ChatItem extends StatelessWidget {

  final ChatMessageObject message;
  final ChatMessageObject? replyTo;
  final void Function(ChatMessageObject obj) onLongPress;
  final void Function(ChatMessageObject obj) onPress;
  final void Function(ChatMessageObject obj) onSwipe;

  const ChatItem({super.key, required this.message , this.replyTo, required this.onLongPress, required this.onSwipe, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        SwipeTo(
          onRightSwipe: null,
          onLeftSwipe: null,
          child: ChatMessageContent(
            onLongPress: () => onLongPress(message),
            onPress: () => onPress(message),
            messageObject: message,
            replyObject: null,
          ), //null for now :")
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: message.self ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Visibility(
                visible: message.state != ChatMessageObject.STATE_SENT,
                child: Row(
                  children: [
                    Text(
                      message.state == ChatMessageObject.STATE_SENDING ? "Sending..."
                          :
                      message.state == ChatMessageObject.STATE_FAILED ? "Failed to send" : "Sent"
                      ,
                      style: TextStyle(
                        color:  message.state != ChatMessageObject.STATE_FAILED ? Colors.grey.shade600 : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Baseline(
                      baseline: 8,
                      baselineType: TextBaseline.alphabetic,
                      child: Text("." , textAlign: TextAlign.center , style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),),
                    ),
                    const SizedBox(width: 5,),
                  ],
                ),
              ),

              Text(
                DateFormat('hh:mm a').format(message.time!),
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatMessageContent extends StatelessWidget {
  final ChatMessageObject messageObject;
  final ChatMessageObject? replyObject;
  final void Function() onLongPress;
  final void Function() onPress;
  const ChatMessageContent({super.key, required this.messageObject , required this.replyObject, required this.onLongPress, required this.onPress});

  Widget _getMediaObjectFor(ChatMessageObject object , BuildContext context){
    if (object.media == null) {
      return const SizedBox.shrink();
    }

    if (object.media!.type == MediaType.VIDEO){
      return Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: VideoPlayerWidget(videoUrl: object.media!.link,),
      );
    }else{
      return Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: object.media!.link.startsWith("/") ? Image.file(File(object.media!.link)) :  Image.network(object.media!.link,),
      );
    }
  }

  Widget _getReplyObject(BuildContext context){
    if (replyObject == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        color: Colors.grey.shade300,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              replyObject!.text ?? "Sent Media",
              softWrap: true,
              maxLines: null,
              //overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          (replyObject!.media != null && replyObject!.media!.type == MediaType.IMAGE) ? Container(
            width: 50,
            height: 50,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(replyObject!.media!.link),
                fit: BoxFit.fill,
              ),
            ),
          ) : const SizedBox.shrink(),
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

        Stack(
          fit: StackFit.passthrough,

          children: [
            //juts a dummy widget to fill the rect under the actual container
            replyObject != null ?
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: messageObject.self ? Alignment.centerRight : Alignment.centerLeft,
                  height: 25,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 8,
                      bottom: 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                    ),
                    //This is just a dummy widget
                    child: Opacity(
                      opacity: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              replyObject!.text ?? "Sent media",
                              softWrap: true,
                              maxLines: null,
                              //overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ) : const SizedBox.shrink(),

            //Text Content
            Align(
              alignment: messageObject.self ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                alignment: messageObject.self ? Alignment.centerRight : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: messageObject.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Material(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        onLongPress: onLongPress,
                        onTap: onPress,
                        child: _getMediaObjectFor(messageObject , context),
                      ),
                    ),
                    Visibility(
                      visible: messageObject.text != null,
                      child: Column(
                        children: [
                          SizedBox.square(dimension: messageObject.media == null ? 0 : 5,),
                          Material(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: messageObject.self ? const Radius.circular(20) :  const Radius.circular(6),
                              bottomRight: messageObject.self ? const Radius.circular(6) :  const Radius.circular(20),
                            ),
                            color: messageObject.self ? Colors.blue : Colors.blueGrey,
                            child: InkWell(

                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: messageObject.self ? const Radius.circular(20) :  const Radius.circular(6),
                                bottomRight: messageObject.self ? const Radius.circular(6) :  const Radius.circular(20),
                              ),
                              onLongPress: onLongPress,
                              onTap: onPress,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  messageObject.text ?? "dummy text",
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

