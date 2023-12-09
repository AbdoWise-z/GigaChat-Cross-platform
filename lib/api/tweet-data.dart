import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/user-class.dart';

enum TweetType {
  TWEET,
  REPLY
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

  final MediaType mediaType;
  final String? media;
  final List<MediaObject> mediaL;

  int viewsNum;
  int likesNum;
  int repliesNum;
  int repostsNum;

  final DateTime creationTime;

  final String type;

  final User tweetOwner;

  bool isLiked;

  bool isRetweeted;
  User? reTweeter;

  TweetData({
    required this.id,
    required this.referredTweetId,
    required this.description,
    this.mediaL = const [],
    required this.viewsNum,
    required this.likesNum,
    required this.repliesNum,
    required this.repostsNum,
    required this.creationTime,
    required this.type,
    required this.tweetOwner,
    required this.isLiked,
    this.reTweeter,
    required this.isRetweeted,
    required this.mediaType,
    required this.media,
  });
}
