
import 'package:gigachat/api/api.dart';

enum MediaType{
  IMAGE,
  VIDEO,
}

class TweetData
{
  final String id;
  final String referredTweetId;
  final String description;

  final MediaType? mediaType;
  final String? media;

  final int viewsNum;
  int likesNum;
  final int repliesNum;
  final int repostsNum;

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
