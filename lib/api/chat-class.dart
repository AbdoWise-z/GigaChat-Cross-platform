
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