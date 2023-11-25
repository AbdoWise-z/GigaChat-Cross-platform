
import 'package:gigachat/util/user-data.dart';

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


// A Tweet Data Object For Testing
TweetData getDefaultTweet(){
  return TweetData(
      id: '1',
      referredTweetId: '',

      description:
      "when i woke up ... i was riding in a flower carriage, it was my birthday,"
          "loremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremloremloremloremlorem"
          "loremloremloremloremloremloremloremloremloremloremloremlorem",


      mediaType: MediaType.IMAGE,
      media:
      "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",

      viewsNum: 12,
      likesNum: 999,
      repliesNum: 1,
      repostsNum: 0,
      creationTime: DateTime(2022, 5, 30, 12, 24, 30),
      type: "Masterpiece", tweetOwner: User(name: "Osama",id: "Lolli-simp"),

      isLiked: false,
    isRetweeted: false
  );
}