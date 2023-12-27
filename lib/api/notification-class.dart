/// a class that represents a notification inside [NotificationsAllTab]
/// [id] the id of the notification
/// [description] the text description of the notification
/// [type] the type of the notification, one of :
///   * follow
///   * like
///   * reply
///   * quote
///   * retweet
///   * mention
///   * chat
///  [creationTime] the time the notification was created at
///  [img] the image of this notification
///  [targetID] the destination of this notification
///  [seen] was this notification seen by the user
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