
import 'package:gigachat/api/media-class.dart';

import '../base.dart';

class ChatObject {
  String lastMessage;
  final String username;
  final String nickname;
  final String profileImage;
  bool pinned;
  DateTime? time;

  ChatObject({
    this.lastMessage = "this is a last message",
    this.username = "Postman",
    this.nickname = "Postman",
    this.profileImage = USER_DEFAULT_PROFILE,
    this.pinned = false,
    this.time,
  }) {
    time = time ?? DateTime.now();
  }
}


class ChatMessageObject {
  static const int STATE_SENDING = 0;
  static const int STATE_SENT    = 1;
  static const int STATE_READ    = 2;
  static const int STATE_FAILED  = 2;

  String id;
  String? replyTo;
  String text;
  MediaObject? media;
  bool self;
  int state;
  DateTime? time;

  //ChatMessageObject({required this.id, required this.text, required this.media, required this.self , required this.time , required this.state , required this.replyTo});
  ChatMessageObject({this.id = "", this.text = "", this.media, this.self = false , this.time , this.state = ChatMessageObject.STATE_SENDING , this.replyTo});


  Map<String,dynamic> toMap(String sender , String receiver){
    return {
      "to" : receiver,
      "from" : sender,
      "id" : id,
      "media" : media != null ?  {
        "type" : media!.type == MediaType.VIDEO ? "video" : "image",
        "link" : media!.link ,
      } : "none",
      "content": text,
      "time": time == null ? DateTime.now().toIso8601String() : time!.toIso8601String(),
    };
  }

  void fromMap(Map<dynamic,dynamic> map, String userID){
    id = map["id"];
    replyTo = null;
    text = map["content"];
    self = map["from"] == userID;
    media = map["media"] != "none" ? MediaObject(link: map["media"]["link"], type: map["media"]["type"] == "video" ? MediaType.VIDEO : MediaType.IMAGE): null;
    time = map["time"] != null ? DateTime.tryParse(map["time"]) : DateTime.now();
    time ??= DateTime.now();
    state = STATE_SENT; //this message should be coming from the web (aka already sent)
  }

}