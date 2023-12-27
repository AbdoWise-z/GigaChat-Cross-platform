import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/pages/search/search-result.dart';
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

/// converts the given input text into RichText Widget having the words starting with # and @ colored in blue and navigates to search page
/// with their values, and normal text will be made as a normal TextSpan
/// [context] : current buildContext of the parent widget
/// [inputText] : the text to be converted
/// [isDarkMode] : if the current theme is dark
/// [currentID] : currently logged in User ID
List<TextSpan> textToRichText(BuildContext? context, String inputText,bool isDarkMode , currentID){
  final RegExp regex = RegExp(r'\B[@#]\w*');
  List<TextSpan> spans = [];
  inputText.splitMapJoin(
    regex,
    onMatch: (Match match) {
      spans.add(
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (context != null) {
                  if (match.group(0)!.startsWith("@")){
                    String user = match.group(0)!.substring(1);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfile(username: user, isCurrUser: currentID == user)));
                  }else {
                    Navigator.pushNamed(
                        context, SearchResultPage.pageRoute, arguments: {
                      "keyword": match.group(0)
                    });
                  }
                }
              },
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

/// UI Representation to the tweet data
/// [tweetOwner] : owner of the given tweet data
/// [tweetData] : data of the tweet to show
/// [isRetweet] : is the current tweet type is retweet
/// [isSinglePostView] : is the current post special post and its ui should change for the main tweet in view post
/// [cancelSameUserNavigation] : stop navigation to the current user profile when clicking on the user avatar of the tweet owner
/// [callBackToDelete] callback function on pressing delete tweet button
/// [onCommentButtonClicked] callback function on pressing comment tweet button
/// [parentFeed] : the feed controller of the feed holding this tweet
/// [deleteOnUndoRetweet] : chooses whether to delete the tweet on undo retweet button pressed or not
/// [showVerticalDivider] : show a vertical line below the user avatar
class Tweet extends StatefulWidget {

  final User tweetOwner;
  final TweetData tweetData;
  final bool isRetweet;
  final bool isSinglePostView;
  final bool cancelSameUserNavigation;
  final void Function(String) callBackToDelete;
  final void Function() onCommentButtonClicked;
  final FeedController? parentFeed;
  final bool? deleteOnUndoRetweet;
  final bool? showVerticalDivider;

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
    this.deleteOnUndoRetweet,
    this.showVerticalDivider = false,
  });

  @override
  State<Tweet> createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  late List<Widget> actionButtons;

  // Controllers for the tweet class

  /// updates parent feed state if found or else updates itself
  void updateState(){
    if (widget.parentFeed == null) {
      setState(() {});
    }
    else {
      if (kDebugMode) {
        print("here");
      }
      widget.parentFeed!.updateFeeds();
    }
  }

  /// navigates to the tweet owner id if it was not the same as the currently logged in user
  /// or it was allowed to navigate to the same user profile
  /// [currentUserId] username of currently logged in user
  /// [tweetOwnerId] id of the tweet owner
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
    FeedProvider feedProvider = FeedProvider.getInstance(context);

    int rowCount = widget.tweetOwner.name.length + widget.tweetOwner.id.length +
        InputFormatting.calculateDateSincePost(widget.tweetData.creationTime).length;

    actionButtons = initActionButtons(
        context: context,
        tweetData: widget.tweetData,
        singlePostView: widget.isSinglePostView,
        onCommentButtonClicked: () async {
          await commentTweet(context, widget.tweetData,widget.parentFeed);
          if(context.mounted && widget.parentFeed != null) {
            feedProvider.updateProfileFeed(context, UserProfile.profileFeedPosts,isCurrProfile: widget.parentFeed!.isInProfile);
            feedProvider.updateProfileFeed(context, UserProfile.profileFeedLikes,isCurrProfile: widget.parentFeed!.isInProfile);
          }
        },
        onRetweetButtonClicked: () async {
          bool isRetweeting = !widget.tweetData.isRetweeted;
          bool success =  await toggleRetweetTweet(currentUser.auth,widget.tweetData);
          if (!isRetweeting){
            if (widget.parentFeed != null && (widget.deleteOnUndoRetweet ?? false)) {
              widget.parentFeed?.deleteTweet(widget.tweetData.id);
            }
            if(success && context.mounted){
              Auth.getInstance(context).getCurrentUser()!.numOfPosts--;
            }
            updateState();
          }
          else{
            if(success && context.mounted){
              Auth.getInstance(context).getCurrentUser()!.numOfPosts++;
            }
            updateState();
          }
          if(context.mounted && success) {
            feedProvider.updateProfileFeed(context, UserProfile.profileFeedPosts,isCurrProfile: widget.parentFeed!.isInProfile);
            feedProvider.updateProfileFeed(context, UserProfile.profileFeedLikes,isCurrProfile: widget.parentFeed!.isInProfile);
          }
          return success;
        },
        onLikeButtonClicked: () async{
          bool isLiked = widget.tweetData.isLiked;
          bool success =  await toggleLikeTweet(context,currentUser.auth,widget.tweetData);
          if (success){
            if(isLiked && context.mounted){
              Auth.getInstance(context).getCurrentUser()!.numOfLikes--;
            }else if (context.mounted){
              Auth.getInstance(context).getCurrentUser()!.numOfLikes++;
            }
            updateState();
          }
          if(context.mounted) {
            feedProvider.updateProfileFeed(context, UserProfile.profileFeedPosts,isCurrProfile: widget.parentFeed!.isInProfile);
            feedProvider.updateProfileFeed(context, UserProfile.profileFeedLikes,isCurrProfile: widget.parentFeed!.isInProfile);
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Table(
                  columnWidths: {
                    0 : FixedColumnWidth(!widget.isSinglePostView ? 40 : 0),
                    1 : FixedColumnWidth(!widget.isSinglePostView ? 5 : 0),
                    2 : const FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        // =================== user avatar ===================
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.fill,
                          child: Visibility(
                            visible: !widget.isSinglePostView,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Visibility(
                                    visible: widget.tweetData.type == "retweet" && widget.tweetData.reTweeter != null,
                                    child: const Icon(FontAwesomeIcons.retweet,size: 15,color: Colors.grey)),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () => navigateToUserProfile(
                                      currentUserId: currentUser.id,
                                      tweetOwnerId: widget.tweetOwner.id
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 20,
                                    backgroundImage: NetworkImage(widget.tweetOwner.iconLink),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Visibility(
                                  visible: widget.showVerticalDivider!,
                                  child: const Expanded(
                                    child: VerticalDivider(
                                      width: 40,
                                      thickness: 2,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // =================== some padding ===================
                        Visibility(
                            visible: !widget.isSinglePostView,
                            child: const SizedBox(width: 5)
                        ),

                        //  =================== Tweet Body ===================
                        Container(
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Visibility(
                                  visible: widget.tweetData.type == "retweet" && !widget.isSinglePostView,
                                  child: widget.tweetData.reTweeter == null ? Container() :
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(currentUser.name == widget.tweetData.reTweeter!.name ?
                                        "You" :
                                        widget.tweetData.reTweeter!.name ,style: const TextStyle(color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Text(" reposted", style: TextStyle(color: Colors.grey)),
                                    ],
                                  )
                              ),
                              // =================== post owner data ===================
                              tweetUserInfo(
                                  context,
                                  widget.tweetData.id,
                                  widget.tweetOwner,
                                  widget.tweetData.creationTime,
                                  widget.isSinglePostView,
                                  isDarkMode,
                                  rowCount
                              ),

                              // =================== extra space for single post view ===================
                              Visibility(
                                  visible: widget.isSinglePostView,
                                  child: const SizedBox(height: 5)
                              ),

                              // Replying To If it's there
                              Visibility(
                                  visible: widget.tweetData.replyingUserId != null,
                                  child: widget.tweetData.replyingUserId == null ? const SizedBox() : Row(
                                    children: [
                                      const Text("Replying to ",style: TextStyle(color: Colors.grey),),
                                      GestureDetector(
                                          onTap: (){
                                            navigateToUserProfile(
                                                currentUserId: currentUser.id,
                                                tweetOwnerId: widget.tweetData.replyingUserId!
                                            );
                                          },
                                          child: Text(
                                            "@${widget.tweetData.replyingUserId!}",
                                            style: const TextStyle(color: Colors.blue),
                                          )
                                      )
                                    ],
                                  )
                              ),

                              Visibility(visible: widget.tweetData.replyingUserId != null,child: const SizedBox(height: 5,)),

                              // =================== post content ===================
                              RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: MAX_LINES_TO_SHOW,
                                  text: TextSpan(
                                      children: textToRichText(context, widget.tweetData.description,isDarkMode , currentUser.id),
                                      style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black
                                      )
                                  )
                              ),

                              // =================== media display here ===================
                              Visibility(
                                visible: (widget.tweetData.media != null),
                                child: widget.tweetData.media == null ? const SizedBox() :
                                TweetMedia(
                                  tweetData: widget.tweetData,
                                  parentFeed: widget.parentFeed,
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
                  ]
              ),
            ),
          );
        }
    );
  }

  /// builds the upper row of the tweet body where the user data is located
  /// [context] current buildContext of the parent widget
  /// [tweetId] id of the current tweet
  /// [tweetOwner] owner of the tweet
  /// [tweetDate] date of the tweet
  /// [isSinglePostView] is it special view for main post in comments page
  /// [isDarkMode] is the current theme is dark
  /// [countRow] number of characters of the name, username and date (to avoid overflowing)
  Widget tweetUserInfo(
      BuildContext context,
      String tweetId,
      User tweetOwner,
      DateTime tweetDate,
      bool isSinglePostView,
      bool isDarkMode,
      int countRow
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
            homeFeed.deleteUserTweets(tweetOwner.id);
            homeFeed.updateFeeds();
            // updateState();
          }) :
          Auth.getInstance(context).follow(tweetOwner.id,success: (followed){
            widget.tweetData.tweetOwner.isFollowed = true;
            updateState();
          });
        }
      }], // ===============================================================
      ["${tweetOwner.isWantedUserMuted! ? "Unmute" : "Mute"} @${tweetOwner.id}", Icons.volume_off, () async {
        if (!tweetOwner.isWantedUserMuted!){
          await Auth.getInstance(context).mute(tweetOwner.id,success: (res){
            tweetOwner.isWantedUserMuted = true;
            updateState();
          });
        }
        else
        {
          await Auth.getInstance(context).unmute(tweetOwner.id,success: (res){
            tweetOwner.isWantedUserMuted = false;
            updateState();
          });
        }

      }], // ===============================================================
      ["Block @${tweetOwner.id}", Icons.block, () async{
        await Auth.getInstance(context).block(tweetOwner.id,tweetOwner.isFollowed!, widget.tweetData.isFollowingMe);
        widget.parentFeed!.deleteUserTweets(tweetOwner.id);
        updateState();
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
                context.mounted ? Navigator.pop(context) : "";
              }
              else {
                if (widget.parentFeed != null){
                  widget.parentFeed!.deleteUserTweets(tweetOwner.id);
                  widget.parentFeed!.updateFeeds();
                }
                if (context.mounted) {
                  Auth.getInstance(context).getCurrentUser()!.numOfPosts--;
                }
              }
              updateState();
            }
          }]
        ];
      }
    }
    final currentUserId = Auth.getInstance(context).getCurrentUser()!.id;
    String formattedDate = InputFormatting.calculateDateSincePost(tweetDate);

    final normalNameAndIdRow = RichText(
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
          style: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.w400),
          children: [
            TextSpan(
                text: tweetOwner.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black
                )
            ),
            TextSpan(text: "@${tweetOwner.id}"),
            TextSpan(text: " . ${formattedDate == "just now" ? "now" : formattedDate}",
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)
            ),
          ]),
    );



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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  tweetOwner.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black
                  ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                  "@${tweetOwner.id}",
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w400
                  ),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ],
    ) :
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        countRow > 25 ?
        Expanded(
            child: normalNameAndIdRow
        ) : normalNameAndIdRow,
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: upperRowNameField,
          ),
        ),

        Visibility(
          visible: isSinglePostView,
          child: SizedBox(
              height: 20,
              width: 100,
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