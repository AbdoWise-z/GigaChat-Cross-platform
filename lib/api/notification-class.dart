class NotificationObject{
  final String id;
  final String description;
  final String type;
  final DateTime creation_time;
  final String img;
  final String targetID;

  NotificationObject({required this.id, required this.description, required this.type, required this.creation_time, this.img = "assets/giga-chat-logo-dark.png" , this.targetID = "backend has fucked up my life"});


}