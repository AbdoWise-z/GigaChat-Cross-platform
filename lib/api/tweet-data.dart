import 'package:gigachat/api/user-class.dart';

enum MediaType{
  IMAGE,
  VIDEO,
}

enum TweetType {
  TWEET,
  REPLY
}

class MediaObject {
  final String link;
  final MediaType type;

  MediaObject({required this.link, required this.type});
}

class IntermediateTweetData{
  final String? referredTweetId;
  final String description;
  final List<MediaObject> media;
  final TweetType type;

  IntermediateTweetData({
    this.referredTweetId,
    required this.description,
    required this.media,
    this.type = TweetType.TWEET,
  });
}

class TweetData
{
  final String id;
  final String referredTweetId;
  final String description;

  final MediaType? mediaType;
  final String? media;

  int viewsNum;
  int likesNum;
  int repliesNum;
  int repostsNum;

  final DateTime creationTime;

  final String type;

  final User tweetOwner;

  bool isLiked;
  bool isRetweeted;

  TweetData({
    required this.id,
    required this.referredTweetId,
    required this.description,
    required this.mediaType,
    required this.media,
    required this.viewsNum,
    required this.likesNum,
    required this.repliesNum,
    required this.repostsNum,
    required this.creationTime,
    required this.type,
    required this.tweetOwner,
    required this.isLiked,
    required this.isRetweeted
  });
}
