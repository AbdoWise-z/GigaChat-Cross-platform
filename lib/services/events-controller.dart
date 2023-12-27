///
/// defines a structure for an event Handler
/// [id] should be a unique id for each handler
/// [handler] is the function to trigger when an
/// event happens
///
class HandlerStructure{
  final String id;
  final void Function (Map<String,dynamic>) handler;

  HandlerStructure({required this.id, required this.handler});
}

///
/// This class will be responsible for triggering and delivering events
/// all over the application, so it acts as a mediator between widgets and widgets
/// or widgets and API functions
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

  /// clears all event handlers
  void clear(){
    _handlers.clear();
  }

  /// and an event handler for an [event] with [HandlerStructure] [handler]
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

  /// removes an event handler for [event] with id [handler]
  void removeEventHandler(String event , String handler){
    List<HandlerStructure>? handlers = _handlers[event];
    if (handlers == null) return;
    handlers.removeWhere((element) => element.id == handler);
    _handlers[event] = handlers;
  }

  //global
  static const String EVENT_LOGIN                    = "login";
  static const String EVENT_LOGOUT                   = "logout";
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
  static const String EVENT_NOTIFICATION_SEEN             = "note-seen";
  static const String EVENT_NOTIFICATIONS_CHANGED         = "note-changed";
  static const String EVENT_NOTIFICATION_RECEIVED         = "note-received";
  static const String EVENT_NOTIFICATION_MENTIONED        = "note-mentioned";

  /// triggers an [event] and sends it to all handlers that accept this type of
  /// event , while also delivering [data] to each of them
  void triggerEvent(String event , Map<String,dynamic> data){
    List<HandlerStructure>? handlers = _handlers[event];
    if (handlers == null) return;
    for (HandlerStructure handler in handlers){
      handler.handler(data);
    }
  }

}