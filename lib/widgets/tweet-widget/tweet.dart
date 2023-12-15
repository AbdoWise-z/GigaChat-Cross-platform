import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/services/input-formatting.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/Follow-Button.dart';
import 'package:gigachat/widgets/bottom-sheet.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';
import 'package:gigachat/widgets/tweet-widget/tweet-media.dart';
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


class Tweet extends StatefulWidget {

  final User tweetOwner;
  final TweetData tweetData;
  final bool isRetweet;
  final bool isSinglePostView;
  final bool cancelSameUserNavigation;
  final void Function(String) callBackToDelete;
  final void Function() onCommentButtonClicked;
  final FeedController? parentFeed;

  const Tweet({
      super.key,
      required this.tweetOwner,
      required this.tweetData,
      required this.isRetweet,
      required this.isSinglePostView,
      required this.callBackToDelete,
      required this.onCommentButtonClicked,
      required this.parentFeed,
      required this.cancelSameUserNavigation
  });

  @override
  State<Tweet> createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  late List<Widget> actionButtons;

  // Controllers for the tweet class
  Future<bool> toggleLikeTweet(BuildContext context,String? token,String tweetId) async {
    if (token == null) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return false;
    }

    bool isLikingTweet = !widget.tweetData.isLiked;
    try {
      bool success = isLikingTweet ?
      await Tweets.likeTweetById(token, tweetId) :
      await Tweets.unlikeTweetById(token, tweetId);

      if (success) {
        widget.tweetData.isLiked = isLikingTweet;
        widget.tweetData.likesNum += widget.tweetData.isLiked ? 1 : -1;
      }
      updateState();
      return success;
    }
    catch(e){
      if (context.mounted) {
        Toast.showToast(context, e.toString());
      }
      return false;
    }
  }

  void updateState(){
    if (widget.parentFeed == null) {
      setState(() {});
    }
    else {
      widget.parentFeed!.updateFeeds();
    }
  }

  Future<bool> toggleRetweetTweet(String? token,String tweetId) async {
    if (token == null){
      return false;
    }

    bool isRetweeting = !widget.tweetData.isRetweeted;
    bool success = isRetweeting ?
    await Tweets.retweetTweetById(token, tweetId) :
    await Tweets.unretweetTweetById(token, tweetId);
    if (success)
    {
      widget.tweetData.isRetweeted = isRetweeting;
      widget.tweetData.repostsNum += widget.tweetData.isRetweeted ? 1 : -1;

      if (!isRetweeting){
        widget.parentFeed?.deleteTweet(tweetId);
      }
      else {
        updateState();
      }
    }
    return success;
  }

  void navigateToUserProfile({required String currentUserId,required String tweetOwnerId}){
    // if it's the same user don't navigate to the profile from the tweet
    if (tweetOwnerId == currentUserId && widget.cancelSameUserNavigation){
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfile(
          username: tweetOwnerId,
          isCurrUser: false
      )),
    );
  }

  // ui part
  @override
  Widget build(BuildContext context) {
    initActionButtons(context, widget.tweetData, widget.isSinglePostView);

    return Consumer<ThemeProvider>(
      builder: (_,__,___) {
        bool isDarkMode = ThemeProvider.getInstance(context).isDark();
        User currentUser = Auth.getInstance(context).getCurrentUser()!;
        return TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero
          ),
          onPressed: widget.isSinglePostView ? () {}
              : () async {
                    await Navigator.pushNamed(context, ViewPostPage.pageRoute, arguments: {
                      "tweetData": widget.tweetData,
                      "tweetOwner": widget.tweetOwner,
                      "cancelNavigationToUser" : widget.cancelSameUserNavigation
                    });
                    if (context.mounted) {
                      setState(() {});
                    }
                  },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // =================== user avatar ===================
                Visibility(
                  visible: !widget.isSinglePostView,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                          visible: widget.tweetData.type == "retweet" && widget.tweetData.reTweeter != null,
                          child: const Icon(FontAwesomeIcons.retweet,size: 15,color: Colors.grey)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => navigateToUserProfile(
                          currentUserId: currentUser.id,
                          tweetOwnerId: widget.tweetOwner.id
                        ),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            // TODO: handle the errors later
                            backgroundImage: NetworkImage(widget.tweetOwner.iconLink),
                        ),
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
                        visible: widget.tweetData.type == "retweet" && !widget.isSinglePostView,
                          child: widget.tweetData.reTweeter == null ? Container() :
                          Text("${currentUser.name == widget.tweetData.reTweeter!.name ? "You" : widget.tweetData.reTweeter!.name } reposted",style: TextStyle(color: Colors.grey),)),
                      // =================== post owner data ===================
                      tweetUserInfo(
                          context,
                          widget.tweetData.id,
                          widget.tweetOwner,
                          widget.tweetData.creationTime,
                          widget.isSinglePostView,
                          isDarkMode
                      ),

                      // =================== extra space for single post view ===================
                      Visibility(
                          visible: widget.isSinglePostView,
                          child: const SizedBox(height: 5)
                      ),

                      // =================== post content ===================
                    RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: MAX_LINES_TO_SHOW,
                        text: TextSpan(
                            children: textToRichText(widget.tweetData.description,isDarkMode),
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black
                            )
                        )
                    ),


                      // =================== media display here ===================
                      // TODO: add video player and retweet
                      Visibility(
                        visible: (widget.tweetData.media != null),
                        child: widget.tweetData.media == null ? const SizedBox() :
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 300
                          ),
                          child: TextButton(
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: TweetMedia(mediaList: widget.tweetData.media!)
                              )
                          ),
                        ),

                      ),
                      // =================== first row of single post view ===================
                      Visibility(
                          visible: widget.isSinglePostView,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: RichText(
                                  text: TextSpan(
                                      text: DateFormat("hh:mm a . d MMMM yy . ").format(widget.tweetData.creationTime),
                                      style: const TextStyle(color: Colors.grey),
                                      children: [
                                        TextSpan(
                                            text: NumberFormat.compact().format(widget.tweetData.viewsNum),
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
                      Visibility(visible: widget.isSinglePostView, child: const Divider(thickness: 2,height: 1)),

                      // =================== second row of single post view ===================
                      Visibility(
                          visible: widget.isSinglePostView,
                          child: Row(
                            children: [
                              TextButton(
                                  onPressed: (){
                                    Navigator.pushNamed(context, UserListViewPage.pageRoute,
                                      arguments: {
                                        "pageTitle": "Reposted By",
                                        "tweetID" : widget.tweetData.id,
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
                                        "${widget.tweetData.repostsNum} ",
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
                                          "tweetID" : widget.tweetData.id,
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
                                          "${widget.tweetData.likesNum} ",
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
                      Visibility(visible: widget.isSinglePostView, child: const Divider(thickness: 2,height: 1)),


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
                      Visibility(visible: widget.isSinglePostView, child: const Divider(thickness: 2,height: 10)),

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

        onPressed: widget.onCommentButtonClicked,
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
                if (widget.parentFeed == null ){
                  Navigator.pop(context);
                }
                else {
                  widget.parentFeed?.deleteTweet(tweetId);
                }
                updateState();
              }
          }]
        ];
      }
    }
    final currentUserId = Auth.getInstance(context).getCurrentUser()!.id;
    final upperRowNameField = isSinglePostView ?
    Row(
      children: [
        GestureDetector(
          onTap: () => navigateToUserProfile(
              currentUserId: currentUserId,
              tweetOwnerId: tweetOwner.id
          ),
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: NetworkImage(tweetOwner.iconLink)
          ),
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

        upperRowNameField,

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
