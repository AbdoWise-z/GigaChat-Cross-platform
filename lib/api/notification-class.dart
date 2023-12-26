class NotificationObject{
  final String id;
  final String description;
  final String type;
  final DateTime creationTime;
  final String img;
  final String targetID;
  bool seen;

  NotificationObject({required this.id, required this.description, required this.type, required this.creationTime, this.img = "assets/giga-chat-logo-dark.png" , this.targetID = "backend has fucked up my life" , this.seen = false});


}