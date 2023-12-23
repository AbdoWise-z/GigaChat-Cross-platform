
import 'package:gigachat/api/media-class.dart';

import '../base.dart';

class ChatObject {
  String lastMessage;
  bool lastMessageSeen;
  String lastMessageSender;
  final String username;
  final String nickname;
  final String profileImage;
  final String mongoID;
  bool blocked;
  bool followed;
  bool isFollowingMe;

  bool pinned;
  DateTime? time;

  ChatObject({
    this.lastMessage = "this is a last message",
    this.lastMessageSeen = false,
    this.blocked = false,
    this.followed = false,
    this.lastMessageSender = "",
    this.username = "Postman",
    this.nickname = "Postman",
    this.mongoID  = "",
    this.profileImage = USER_DEFAULT_PROFILE,
    this.pinned = false,
    this.time,
    this.isFollowingMe = false,
  }) {
    time = time ?? DateTime.now();
  }
}


class ChatMessageObject {
  static const int STATE_SENDING = 0;
  static const int STATE_SENT    = 1;
  static const int STATE_READ    = 2;
  static const int STATE_FAILED  = 2;

  String uuid;
  String id;
  String? replyTo;
  String? text;
  MediaObject? media;
  bool self;
  bool seen;
  int state;
  DateTime? time;

  //ChatMessageObject({required this.id, required this.text, required this.media, required this.self , required this.time , required this.state , required this.replyTo});
  ChatMessageObject({this.uuid = "" , this.seen = false , this.id = "" , this.text = "", this.media, this.self = false , this.time , this.state = ChatMessageObject.STATE_SENDING , this.replyTo});


  Map<String,dynamic> toMap(String sender , String receiver){
    return {
      //"to" : receiver,
      //"from" : sender,
      "reciever_ID": receiver,
      "data": {
        "id" : uuid,
        "media" : media != null ?  {
          "type" : media!.type == MediaType.VIDEO ? "video" : "image",
          "link" : media!.link ,
        } : null,
        "text": text,
      },
      //"time": time == null ? DateTime.now().toIso8601String() : time!.toIso8601String(),
    };
  }

  void fromMap(Map<dynamic,dynamic> map){
    uuid = map["id"] ?? "";
    id   = map["message"]["id"] ?? "";
    replyTo = null;
    text = map["message"]["description"];
    self = map["message"]["mine"]; //map["from"] == userID;
    media = map["message"]["media"] != null && map["message"]["media"]["link"] != null ? MediaObject(link: map["message"]["media"]["link"], type: map["message"]["media"]["type"] == "video" ? MediaType.VIDEO : MediaType.IMAGE): null;
    time = map["message"]["sendTime"] != null ? DateTime.tryParse(map["message"]["sendTime"]) : DateTime.now();
    seen = true;
    state = STATE_SENT; //this message should be coming from the web (aka already sent)
  }

  void fromDirectMap(Map<dynamic,dynamic> map){
    uuid = "";
    id   = map["id"] ?? "";
    replyTo = null;
    text = map["description"];
    self = map["mine"]; //map["from"] == userID;
    media = map["media"] != null && map["media"]["link"] != null ? MediaObject(link: map["media"]["link"], type: map["media"]["type"] == "video" ? MediaType.VIDEO : MediaType.IMAGE): null;
    time = map["sendTime"] != null ? DateTime.tryParse(map["sendTime"]) : DateTime.now();
    seen = map["seen"];
    state = STATE_SENT; //this message should be coming from the web (aka already sent)
  }

}