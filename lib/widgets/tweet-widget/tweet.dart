import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/services/input-formatting.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/Follow-Button.dart';
import 'package:gigachat/widgets/bottom-sheet.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';
import 'package:gigachat/widgets/video-player.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// tested successfully
List<TextSpan> textToRichText(String inputText,bool isDarkMode){
  final RegExp regex = RegExp(r'\B#\w*');
  List<TextSpan> spans = [];
  inputText.splitMapJoin(
    regex,
    onMatch: (Match match) {
      spans.add(
          TextSpan(
            text: match.group(0),
            style: const TextStyle(
                color: Colors.blue
            ),
          )
      );
      return match.group(0)!;
    },
    onNonMatch: (String nonMatch) {
      if (nonMatch.isNotEmpty) {
        spans.add(TextSpan(text: nonMatch));
      }
      return nonMatch;
    },
  );
  return spans;

}


class Tweet extends StatelessWidget {

  final User tweetOwner;
  final TweetData tweetData;
  late List<Widget> actionButtons;
  final bool isRetweet;
  final bool isSinglePostView;
  final void Function(String) callBackToDelete;

  Tweet({
      super.key,
      required this.tweetOwner,
      required this.tweetData,
      required this.isRetweet,
      required this.isSinglePostView,
      required this.callBackToDelete
  });


  // Controllers for the tweet class
  Future<bool> toggleLikeTweet(BuildContext context,String? token,String tweetId) async {
    if (token == null) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return false;
    }
    
    bool isLikingTweet = !tweetData.isLiked;
    try {
      bool success = isLikingTweet ?
      await Tweets.likeTweetById(token, tweetId) :
      await Tweets.unlikeTweetById(token, tweetId);

      if (success) {
        tweetData.isLiked = isLikingTweet;
        tweetData.likesNum += tweetData.isLiked ? 1 : -1;
      }
      return success;
    }
    catch(e){
      Toast.showToast(context, e.toString());
      return false;
    }
  }

  Future<bool> toggleRetweetTweet(String? token,String tweetId) async {
    if (token == null){
      return false;
    }

    bool isRetweeting = !tweetData.isRetweeted;
    bool success = isRetweeting ? await Tweets.retweetTweetById(token, tweetId) : await Tweets.unretweetTweetById(token, tweetId);
    // TODO: call the interface here and send the tweet id to retweet it
    if (success)
    {
      tweetData.isRetweeted = isRetweeting;
      tweetData.repostsNum += tweetData.isRetweeted ? 1 : -1;
    }
    return success;
  }

  // ui part
  @override
  Widget build(BuildContext context) {
    initActionButtons(context, tweetData, isSinglePostView);

    return Consumer<ThemeProvider>(
      builder: (_,__,___) {
        bool isDarkMode = ThemeProvider.getInstance(context).isDark();
        String currentUserName = Auth.getInstance(context).getCurrentUser()!.name;
        return TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero
          ),
          onPressed: isSinglePostView ? () {}
              : () {
                  Navigator.pushNamed(context, ViewPostPage.pageRoute, arguments: {
                    "tweetData": tweetData,
                    "tweetOwner": tweetOwner
                  });
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // =================== user avatar ===================
                Visibility(
                  visible: !isSinglePostView,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                          visible: tweetData.type == "retweet" && tweetData.reTweeter != null,
                          child: const Icon(FontAwesomeIcons.retweet,size: 15,color: Colors.grey)),
                      const SizedBox(height: 10),
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          // TODO: handle the errors later
                          backgroundImage: NetworkImage(tweetOwner.iconLink),
                      ),
                    ],
                  ),
                ),


                // =================== some padding ===================
                const SizedBox(width: 10),

                //  =================== Tweet Body ===================
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Visibility(
                        visible: tweetData.type == "retweet" && !isSinglePostView,
                          child: tweetData.reTweeter == null ? Container() :
                          Text("${currentUserName == tweetData.reTweeter!.name ? "You" : tweetData.reTweeter!.name } reposted",style: TextStyle(color: Colors.grey),)),
                      // =================== post owner data ===================
                      tweetUserInfo(
                          context,
                          tweetData.id,
                          tweetOwner,
                          tweetData.creationTime,
                          isSinglePostView,
                          isDarkMode
                      ),

                      // =================== extra space for single post view ===================
                      Visibility(
                          visible: isSinglePostView,
                          child: const SizedBox(height: 5)
                      ),

                      // =================== post content ===================
                    RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: MAX_LINES_TO_SHOW,
                        text: TextSpan(
                            children: textToRichText(tweetData.description,isDarkMode),
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black
                            )
                        )
                    ),


                      // =================== media display here ===================
                      // TODO: add video player and retweet
                      Visibility(
                        visible: (tweetData.media != null),
                        child: tweetData.media == null ? const SizedBox() :
                        TextButton(
                            onPressed: () {/* TODO: open full screen image*/},
                            onLongPress: () {
                            showModalBottomSheet(
                              showDragHandle: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20))),
                              context: context,
                              builder: (context) => buildSheet(context, [
                                ["Post Photo", Icons.add_circle_outline, () {
                                    // TODO: send the image to the add new post page and navigate
                                }],
                                ["Save Photo", Icons.download, () {
                                    // TODO: save the image to the device
                                }]
                              ]),
                            );
                          },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                            ),
                            child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                                width: double.infinity,
                                constraints: const BoxConstraints(maxHeight: 400),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0,),
                                ),
                                child: tweetData.mediaType == MediaType.VIDEO ?
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child:VideoPlayerWidget(
                                      videoUrl: tweetData.media!,

                                  )
                                ) :
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    tweetData.media!,fit:BoxFit.fill,
                                    loadingBuilder: (context,child,loadingProgress){
                                      return loadingProgress == null ? child :
                                      Container(
                                        color: Colors.transparent,
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (_,exception, stack){
                                      return Container(
                                        color: Colors.transparent,
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.warning_amber,color:Colors.red),
                                              Text("something went wrong",style: TextStyle(color: Colors.red),)
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )),
                        ),

                      ),
                      // =================== first row of single post view ===================
                      Visibility(
                          visible: isSinglePostView,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                      text: DateFormat("hh:mm a . d MMMM yy . ").format(tweetData.creationTime),
                                      style: const TextStyle(color: Colors.grey),
                                      children: [
                                        TextSpan(
                                            text: NumberFormat.compact().format(tweetData.viewsNum),
                                            style: TextStyle(
                                                color: isDarkMode ? Colors.white : Colors.black,
                                                fontWeight: FontWeight.bold
                                            )
                                        ),
                                        const TextSpan(text: " Views")
                                      ]
                                  ),
                                ),
                              )
                            ],
                          )
                      ),

                      // =================== divider one ===================
                      Visibility(visible: isSinglePostView, child: const Divider(thickness: 2,height: 1)),

                      // =================== second row of single post view ===================
                      Visibility(
                          visible: isSinglePostView,
                          child: Row(
                            children: [
                              TextButton(
                                  onPressed: (){
                                    Navigator.pushNamed(context, UserListViewPage.pageRoute,
                                      arguments: {
                                        "pageTitle": "Reposted By",
                                        "tweetID" : tweetData.id,
                                        "providerType" : UserListViewFunction.GET_TWEET_REPOSTERS
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding:const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.grey
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "${tweetData.repostsNum} ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white : Colors.black
                                        )
                                      ),
                                      const Text(" Reposts"),
                                    ],
                                  )
                              ),

                              TextButton(
                                  onPressed: (){
                                    Navigator.pushNamed(context, UserListViewPage.pageRoute,
                                        arguments: {
                                          "pageTitle": "Liked By",
                                          "tweetID" : tweetData.id,
                                          "providerType" : UserListViewFunction.GET_TWEET_LIKERS
                                        });
                                  },
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 15),
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.grey
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                          "${tweetData.likesNum} ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode ? Colors.white : Colors.black
                                          )
                                      ),
                                      const Text(" Likes"),
                                    ],
                                  )
                              ),

                            ],
                          )),

                      // =================== divider two ===================
                      Visibility(visible: isSinglePostView, child: const Divider(thickness: 2,height: 1)),


                      // =================== action buttons row ===================
                      Container(
                        padding: EdgeInsets.zero,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: actionButtons
                                .map((actionBtn) => actionBtn)
                                .toList()),
                      ),

                      // =================== divider three ===================
                      Visibility(visible: isSinglePostView, child: const Divider(thickness: 2,height: 10)),

                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }



  void initActionButtons(BuildContext context, TweetData tweetData, bool singlePostView) {
    String? userToken = Auth.getInstance(context).getCurrentUser()!.auth;

    actionButtons = [
      TweetActionButton(
        icon: FontAwesomeIcons.comment,
        count: singlePostView ? null : tweetData.repliesNum,

        isLikeButton: false,
        isLiked: false,

        isRetweet: false,
        isRetweeted: false,

        onPressed: () async {
          dynamic retArguments = await Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {
            "reply" : tweetData,
          });
          if(retArguments["success"] != null && retArguments["success"] == true){
            tweetData.repliesNum += 1;
          }
          print("tweet prints ${tweetData.repliesNum}");
          return tweetData.repliesNum;
        },
      ),
      TweetActionButton(
        icon: FontAwesomeIcons.retweet,
        count: singlePostView ? null : tweetData.repostsNum,

        isLikeButton: false,
        isLiked: tweetData.isRetweeted,

        isRetweet: true,
        isRetweeted: tweetData.isRetweeted,

        onPressed: () async {
          return await toggleRetweetTweet(userToken,tweetData.id);
        }
      ),
      TweetActionButton(
        icon: FontAwesomeIcons.heart,
        count: singlePostView ? null : tweetData.likesNum,

        isLikeButton: true,
        isLiked: tweetData.isLiked,

        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,

        onPressed: (){
          return toggleLikeTweet(context,userToken,tweetData.id);
        }
      ),
      TweetActionButton(
        icon: Icons.bar_chart,
        count: singlePostView ? null : tweetData.viewsNum,

        isLikeButton: false,
        isLiked: false,

        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,

        onPressed: (){}
      ),
      TweetActionButton(
        icon: Icons.share_outlined,
        count: null,

        isLikeButton: false,
        isLiked: false,

        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,

        onPressed: () {}
      ),
    ];
  }

  Widget tweetUserInfo(
      BuildContext context,
      String tweetId,
      User tweetOwner,
      DateTime tweetDate,
      bool isSinglePostView,
      bool isDarkMode
      )
  {
    List<List> dotsBottomSheetData = [
          // ===============================================================
      ["Not interested in ${tweetOwner.name}", Icons.cancel_outlined, () {

      }], // ===============================================================
      ["Not interested in this post", FontAwesomeIcons.faceFrown, () {

      }], // ===============================================================
      [],
      ["Follow @${tweetOwner.id}", Icons.person_add_alt_1_outlined, () {
          // TODO: call the api to follow the post owner
      }], // ===============================================================
      ["Mute @${tweetOwner.id}", Icons.volume_off, () {
          // TODO: call the api to mute the post owner
      }], // ===============================================================
      ["Block @${tweetOwner.id}", Icons.block, () {
          // TODO: call the api to block the post owner
      }], // ===============================================================
    ];
    if (Auth.getInstance(context).getCurrentUser() != null){
      String? currentUserToken = Auth.getInstance(context).getCurrentUser()!.auth;
      String currentUserId = Auth.getInstance(context).getCurrentUser()!.id;
      if (tweetOwner.id == currentUserId){
        dotsBottomSheetData = [
          ["Delete post",Icons.delete,() async {
              bool success = await Tweets.deleteTweetById(currentUserToken!,tweetId);
              if (success){
                callBackToDelete(tweetId);
              }
          }]
        ];
      }
    }

    final upperRowNameField = isSinglePostView ?
    Row(
      children: [
        CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            backgroundImage: NetworkImage(tweetOwner.iconLink)
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tweetOwner.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black
                )
            ),
            Text(
                "@${tweetOwner.id}",
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w400
                )
            )
          ],
        ),
      ],
    ) :
    Row(
      children: [
        Text(
            tweetOwner.name,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black
            )
        ),
        RichText(
            text: TextSpan(
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w400),
                children: [
              TextSpan(text: "@${tweetOwner.id}"),
              TextSpan(
                  text:
                      " . ${InputFormatting.calculateDateSincePost(tweetDate)}")
            ])),
      ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile(
                    username: tweetOwner.id,
                    isCurrUser: false
                )),
              );
            },
            child: upperRowNameField
        ),

        const Expanded(child: SizedBox()),

        Visibility(
          visible: isSinglePostView,
          child: SizedBox(
              height: 20,
              width: 80,
              // TODO: must be changed to whatever the current user state with this post owner
              child: Visibility(
                visible: tweetOwner.id != Auth.getInstance(context).getCurrentUser()!.id,
                child: FollowButton(
                    isFollowed: tweetOwner.isFollowed ?? false,
                    callBack: (bool followed) {},
                    username: tweetOwner.id
                ),
              )
          ),
        ),
        SizedBox(
          height: 30,
          width: 30,
          child: IconButton(
            onPressed: () {
              showCustomModalSheet(context, dotsBottomSheetData);
            },
            iconSize: 20,
            splashRadius: 20,
            icon: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
