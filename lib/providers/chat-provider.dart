
import 'package:flutter/cupertino.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/chat-requests.dart';
import 'package:gigachat/providers/web-socks-provider.dart';
import 'package:gigachat/services/events-controller.dart';

import 'auth.dart';

class ChatProvider extends ChangeNotifier{
  static ChatProvider? _instance;

  ChatProvider._internal();

  factory ChatProvider(){
    _instance ??= ChatProvider._internal();
    return _instance!;
  }

  static ChatProvider get instance {
    return ChatProvider();
  }

  List<ChatObject> _chats = [];
  //Map<String,List<ChatMessageObject>> _messages = {};

  final String HANDLER_NAME = "chat-provider";
  final int CHAT_PROVIDER_COUNT = 35;
  final ChatMessageObject GAB_MESSAGE = ChatMessageObject(uuid: "GAB");

  void init() async {
    _chats = [];
    //_messages = {};

    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_BLOCK,
        HandlerStructure(id: HANDLER_NAME,
          handler: (data) {
            for (ChatObject k in _chats){
              if (k.username == data["username"]){
                k.blocked = true;
                notifyListeners();
                break;
              }
            }
          },
        )
    );
    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_FOLLOW,
        HandlerStructure(id: HANDLER_NAME,
          handler: (data) {
            for (ChatObject k in _chats){
              if (k.username == data["username"]){
                k.followed = true;
                notifyListeners();
                break;
              }
            }
          },
        )
    );
    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_UNFOLLOW,
        HandlerStructure(id: HANDLER_NAME,
          handler: (data) {
            for (ChatObject k in _chats){
              if (k.username == data["username"]){
                k.followed = false;
                notifyListeners();
                break;
              }
            }
          },
        )
    );
    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_UNBLOCK,
        HandlerStructure(id: HANDLER_NAME,
          handler: (data) {
            for (ChatObject k in _chats){
              if (k.username == data["username"]){
                k.blocked = false;
                notifyListeners();
                break;
              }
            }
          },
        )
    );
    EventsController.instance.addEventHandler(
        EventsController.EVENT_USER_BLOCK_ME,
        HandlerStructure(id: HANDLER_NAME,
          handler: (data) {
            for (ChatObject k in _chats){
              if (k.username == data["username"]){
                k.blocked = true;
                notifyListeners();
                break;
              }
            }
          },
        )
    );

    EventsController.instance.addEventHandler(
        EventsController.EVENT_CHAT_MESSAGE_READ,
        HandlerStructure(id: HANDLER_NAME,
          handler: (data) {
            for (ChatObject k in _chats){
              if (k.mongoID == data["mongoID"]){
                k.lastMessage!.seen = true;
                EventsController.instance.triggerEvent(EventsController.EVENT_CHAT_READ_COUNT_CHANGED , {});
                notifyListeners();
                break;
              }
            }
          },
        )
    );



    WebSocketsProvider().getStream<Map<String,dynamic>>("receive_message").stream.listen((event) async {
      var data = event;
      String id = data["chat_ID"];
      print("chat-provider : $data");
      bool found = false;
      for (ChatObject k in _chats){
        if (k.mongoID == id){
          ChatMessageObject obj = ChatMessageObject();
          obj.fromMap(data);
          k.lastMessage = obj;
          obj.seen = obj.self;
          k.time = obj.time;
          EventsController.instance.triggerEvent(EventsController.EVENT_CHAT_MESSAGE, {
            "id" : id,
            "message" : obj,
          });

          EventsController.instance.triggerEvent(EventsController.EVENT_CHAT_READ_COUNT_CHANGED , {});
          // List<ChatMessageObject>? _msg = _messages[k.mongoID];
          // if (_msg != null){
          //   _msg.add(obj);
          //   _messages[k.mongoID] = _msg;
          // }
          found = true;
          notifyListeners();
          break;
        }
      }
      if (!found){ //reload chats
        await reloadChats(Auth().getCurrentUser()!.auth!);
      }
    });

    await reloadChats(Auth().getCurrentUser()!.auth!);
  }

  List<ChatObject> getCurrentChats() {
    return _chats;
  }

  Future<List<ChatObject>> getChats(String token) async {
    if (_chats.isNotEmpty){
      return _chats;
    }
    return reloadChats(token , notify: false);
  }

  Future<List<ChatObject>> reloadChats(String token , {notify = true}) async {
    var k = await Chat.apiGetChats(token, 1, 1000);
    if (k.data != null){
      _chats.clear();
      _chats.addAll(k.data!);
      EventsController.instance.triggerEvent(EventsController.EVENT_CHAT_READ_COUNT_CHANGED , {});
      // _messages.clear();
      // for (ChatObject chat in _chats){
      //   _messages.addAll({
      //     chat.mongoID : [GAB_MESSAGE , chat.lastMessage!]
      //   });
      // }
    }

    if (notify) {
      notifyListeners();
    }
    return _chats;
  }

  //TODO: maybe complete this one day ..
  int _mergePart(List<ChatMessageObject> list , List<ChatMessageObject> part , int direction , int index){
    if (list[index] != GAB_MESSAGE){
      print("failed to merge messages, not a gap");
      return -1;
    }
    if (direction == 1){ //merge up
      int count = 0;
      for (int i = part.length - 1; i >= 0;i--){
        ChatMessageObject to_add = part[i];
        if (index != 0){ //GAB is not at top --> maybe we can remove it
          if (list[index - 1].time == to_add.time){ //we already reached the same message
            list.removeAt(index); //remove the GAB
            return count;
          }
        }
        count++;
        list.insert(index + 1, to_add); //else just add it
      }
      return count;
    }else{ //merge down
      int count = 0;
      int start = index;
      for (int i = 0; i < part.length ;i++){
        ChatMessageObject to_add = part[i];
        if (index != list.length - 1){ //GAB is not at top --> maybe we can remove it
          if (list[index + 1].time == to_add.time){ //we already reached the same message
            list.removeAt(index); //remove the GAB
            list.insert(start, GAB_MESSAGE);
            return count;
          }
        }
        count++;
        list.insert(index++ , to_add); //else just add it
      }
      list.insert(start, GAB_MESSAGE);
      return count;
    }
  }

  Future<List<ChatMessageObject>> getMessagesBefore(String token, String id, DateTime time) async {
    //first try to fetch them from the messages we already have
    var k = await Chat.apiGetChatMessagesBefore(token, id, 1, CHAT_PROVIDER_COUNT, time);
    if (k.data != null){
      return k.data!;
    }
    return [];
  }

  Future<List<ChatMessageObject>> getMessagesAfter(String token, String id, DateTime time) async {
    //first try to fetch them from the messages we already have
    var k = await Chat.apiGetChatMessagesAfter(token, id, 1, CHAT_PROVIDER_COUNT, time);
    if (k.data != null){
      return k.data!;
    }
    return [];
  }
}