import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/media-requests.dart';
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

class MediaData{
  static int tagNumber = 0;
  MediaType mediaType;
  String mediaUrl;
  String? tag;
  MediaData({required this.mediaType, required this.mediaUrl}){
    tag = "Media $mediaUrl $tagNumber";
    tagNumber++;
  }
}

class TweetData
{
  final String id;
  final String? referredTweetId;
  final String description;

  final List<MediaData>? media;
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
    required this.media
  });
}

// TweetData convertToTweetData(String id, IntermediateTweetData intermediateTweetData, User user){
//   return TweetData(
//       id: id,
//       referredTweetId: ,
//       description: description,
//       viewsNum: viewsNum,
//       likesNum: likesNum,
//       repliesNum: repliesNum,
//       repostsNum: repostsNum,
//       creationTime: creationTime,
//       type: type,
//       tweetOwner: tweetOwner,
//       isLiked: isLiked,
//       isRetweeted: isRetweeted,
//       media: media
//   );


// }
