
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';

class ChatObject {
  String lastMessage;
  final String username;
  final String nickname;
  final String profileImage;
  bool pinned;
  DateTime? time;

  ChatObject({
    this.lastMessage = "this is a last message",
    this.username = "@Abdo",
    this.nickname = "Abdo Mohammed",
    this.profileImage = "USER_DEFAULT_PROFILE",
    this.pinned = false,
    this.time,
  }) {
    time = time ?? DateTime.now();
  }
}


class ChatMessageObject {
  static final int STATE_SENDING = 0;
  static final int STATE_SENT    = 1;
  static final int STATE_READ    = 2;

  final String id;
  final String? replyTo;
  final String text;
  final MediaObject? media;
  final bool self;
  int state;
  DateTime? time;

  ChatMessageObject({required this.id, required this.text, required this.media, required this.self , required this.time , required this.state , required this.replyTo});

}