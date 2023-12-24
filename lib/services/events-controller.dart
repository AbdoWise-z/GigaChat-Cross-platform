class HandlerStructure{
  final String id;
  final void Function (Map<String,dynamic>) handler;

  HandlerStructure({required this.id, required this.handler});

}
class EventsController {
  static EventsController? _instance;

  EventsController._internal();

  factory EventsController(){
    _instance ??= EventsController._internal();
    return _instance!;
  }

  static EventsController get instance {
    return EventsController();
  }


  final Map<String,List<HandlerStructure>> _handlers = {};

  void clear(){
    _handlers.clear();
  }

  void addEventHandler(String event , HandlerStructure handler){
    List<HandlerStructure>? handlers = _handlers[event];
    handlers ??= [];
    int index = handlers.indexWhere((element) => element.id == handler.id);
    if (index != -1){
      handlers[index] = handler;
    }else {
      handlers.add(handler);
    }
    _handlers[event] = handlers;
  }

  void removeEventHandler(String event , String handler){
    List<HandlerStructure>? handlers = _handlers[event];
    if (handlers == null) return;
    handlers.removeWhere((element) => element.id == handler);
    _handlers[event] = handlers;
  }

  //global
  static const String EVENT_LOGIN                    = "login";
  static const String EVENT_LOGINOUT                 = "logout";
  static const String EVENT_USER_BLOCK               = "user-block";
  static const String EVENT_USER_BLOCK_ME            = "user-block-me";
  static const String EVENT_USER_UNBLOCK             = "user-unblock";
  static const String EVENT_USER_FOLLOW              = "user-follow";
  static const String EVENT_USER_UNFOLLOW            = "user-unfollow";
  static const String EVENT_USER_MUTE                = "user-mute";
  static const String EVENT_USER_UNMUTE              = "user-unmute";

  //chat
  static const String EVENT_CHAT_MESSAGE             = "chat-message";
  static const String EVENT_CHAT_MESSAGE_READ        = "chat-message-read";
  static const String EVENT_CHAT_READ_COUNT_CHANGED  = "chat-read-count-changed";

  //notifications
  static const String EVENT_NOTIFICATION_SEEN            = "note-seen";
  static const String EVENT_NOTIFICATIONS_CHANGED        = "note-changed";

  void triggerEvent(String event , Map<String,dynamic> data){
    List<HandlerStructure>? handlers = _handlers[event];
    if (handlers == null) return;
    for (HandlerStructure handler in handlers){
      handler.handler(data);
    }
  }

}