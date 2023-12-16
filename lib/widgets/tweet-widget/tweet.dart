import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/pages/feed/feed-home-tab.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/services/input-formatting.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/widgets/Follow-Button.dart';
import 'package:gigachat/widgets/bottom-sheet.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/tweet-widget/common-widgets.dart';
import 'package:gigachat/widgets/tweet-widget/tweet-controller.dart';
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
  final bool? showReplies;
  final bool? onlyOneReply;
  final bool? deleteOnUndoRetweet;

  const Tweet({
      super.key,
      required this.tweetOwner,
      required this.tweetData,
      required this.isRetweet,
      required this.isSinglePostView,
      required this.callBackToDelete,
      required this.onCommentButtonClicked,
      required this.parentFeed,
      required this.cancelSameUserNavigation,
      this.showReplies,
      this.onlyOneReply,
      this.deleteOnUndoRetweet
  });

  @override
  State<Tweet> createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  late List<Widget> actionButtons;

  // Controllers for the tweet class

  void updateState(){
    if (widget.parentFeed == null) {
      setState(() {});
    }
    else {
      print("here");
      widget.parentFeed!.updateFeeds();
    }
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
    User currentUser = Auth.getInstance(context).getCurrentUser()!;

    actionButtons = initActionButtons(
            context: context,
            tweetData: widget.tweetData,
            singlePostView: widget.isSinglePostView,
            onCommentButtonClicked: () async {
               int ret = await commentTweet(context, widget.tweetData,widget.parentFeed);
            },
            onRetweetButtonClicked: () async {
              bool isRetweeting = !widget.tweetData.isRetweeted;
              bool success =  await toggleRetweetTweet(currentUser.auth,widget.tweetData);
              if (!isRetweeting){
                if (widget.parentFeed != null && (widget.deleteOnUndoRetweet ?? false)) {
                  widget.parentFeed?.deleteTweet(widget.tweetData.id);
                }
                updateState();
              }
              else{
                updateState();
              }
              return success;
            },
            onLikeButtonClicked: () async{
              bool success =  await toggleLikeTweet(context,currentUser.auth,widget.tweetData);
              if (success){
                updateState();
              }
              return success;
            }
        );

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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                // =================== user avatar ===================
                Visibility(
                  visible: !widget.isSinglePostView,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
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
                Visibility(
                  visible: !widget.isSinglePostView,
                    child: const SizedBox(width: 10)
                ),

                //  =================== Tweet Body ===================
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
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
                              onPressed: () {},
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
                                child: TweetMedia(
                                    tweetData: widget.tweetData,
                                    parentFeed: widget.parentFeed,
                                )
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
                                        "pageTitle": "Retweeted By",
                                        "tweetID" : widget.tweetData.id,
                                        "userID" : null,
                                        "providerFunction" : ProviderFunction.GET_TWEET_REPOSTERS
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
                                          "userID" : null,
                                          "providerFunction" : ProviderFunction.GET_TWEET_LIKERS
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

  Widget tweetUserInfo(
      BuildContext context,
      String tweetId,
      User tweetOwner,
      DateTime tweetDate,
      bool isSinglePostView,
      bool isDarkMode
      )
  {
    User? currentUser = Auth.getInstance(context).getCurrentUser();
    List<List> dotsBottomSheetData = [
          // ===============================================================
      ["Not interested in ${tweetOwner.name}", Icons.cancel_outlined, () {

      }], // ===============================================================
      ["Not interested in this post", FontAwesomeIcons.faceFrown, () {

      }], // ===============================================================
      [],
      [
        tweetOwner.isFollowed ?? false ? "Unfollow @${tweetOwner.id}" : "Follow @${tweetOwner.id}",
        Icons.person_add_alt_1_outlined, () {
          if(currentUser != null){
            tweetOwner.isFollowed! ?
            Auth.getInstance(context).unfollow(tweetOwner.id,success: (followed){
              widget.tweetData.tweetOwner.isFollowed = false;
              FeedController homeFeed = FeedProvider.getInstance(context).getFeedControllerById(
                  context: context,
                  id: Home.feedID,
                  providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
                  clearData: false
              );
              homeFeed.resetFeed();
              homeFeed.updateFeeds();
              updateState();
            }) :
            Auth.getInstance(context).follow(tweetOwner.id,success: (followed){
              widget.tweetData.tweetOwner.isFollowed = true;
              updateState();
            });
          }
      }], // ===============================================================
      ["Mute @${tweetOwner.id}", Icons.volume_off, () {

      }], // ===============================================================
      ["Block @${tweetOwner.id}", Icons.block, () {
          // TODO: call the api to block the post owner
      }], // ===============================================================
    ];
    if (currentUser != null){
      String? currentUserToken = currentUser.auth;
      String currentUserId = currentUser.id;
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
      mainAxisAlignment: MainAxisAlignment.start,
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
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        upperRowNameField,

        const Expanded(child: SizedBox()),

        Visibility(
          visible: isSinglePostView,
          child: SizedBox(
              height: 20,
              width: 80,
               child: Visibility(
                visible: tweetOwner.id != Auth.getInstance(context).getCurrentUser()!.id,
                child: FollowButton(
                    isFollowed: tweetOwner.isFollowed ?? false,
                    callBack: (bool followed) {tweetOwner.isFollowed = followed;},
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
