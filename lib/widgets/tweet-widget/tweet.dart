import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/services/input-formatting.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/widgets/bottom-sheet.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';
import 'package:gigachat/widgets/video-player.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class Tweet extends StatelessWidget {
  static String pageRoute = "/test";
  final User tweetOwner;
  final TweetData tweetData;
  late List<Widget> actionButtons;
  final bool isRetweet;
  final bool isSinglePostView;

  Tweet({
      super.key,
      required this.tweetOwner,
      required this.tweetData,
      required this.isRetweet,
      required this.isSinglePostView
  });
  // Controllers for the tweet class
  Future<bool> toggleLikeTweet(String? token,String tweetId) async {
    //if (token == null) return true;
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1NTBkMmY5ZjkwODhlODgzMThmZDEwYyIsImlhdCI6MTcwMTEwMzI2NywiZXhwIjoxNzA4ODc5MjY3fQ.Il_1vL2PbOE36g0wW55Lh1M7frJWx73gNIZ0uDuP5yw";

    bool isLikingTweet = !tweetData.isLiked;

    bool success = isLikingTweet ?
    await Tweets.likeTweetById(token, tweetId) :
    await Tweets.unlikeTweetById(token, tweetId);

    if(success){
      tweetData.isLiked = isLikingTweet;
      tweetData.likesNum += tweetData.isLiked ? 1 : -1;
    }
    return success;
  }

  Future<bool> toggleRetweetTweet(String? token,String tweetId) async {
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1NTBkMmY5ZjkwODhlODgzMThmZDEwYyIsImlhdCI6MTcwMTEwMzI2NywiZXhwIjoxNzA4ODc5MjY3fQ.Il_1vL2PbOE36g0wW55Lh1M7frJWx73gNIZ0uDuP5yw";
    if (token == null) return false;

    bool isRetweeting = !tweetData.isRetweeted;
    bool success = await Tweets.retweetTweetById(token, tweetId);
    // TODO: call the interface here and send the tweet id to retweet it
    if (success)
    {
      tweetData.isRetweeted = isRetweeting;
      tweetData.repostsNum += tweetData.isRetweeted ? 1 : -1;
    }
    return tweetData.isRetweeted;
  }

  // ui part
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeProvider.getInstance(context).isDark();
    initActionButtons(context, tweetData, isSinglePostView);

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
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =================== user avatar ===================
            Visibility(
              visible: !isSinglePostView,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(tweetOwner.iconLink)),
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

                  // =================== post owner data ===================
                  tweetUserInfo(
                      context,
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
                  // TODO: make the hashtags and mentions later
                  ReadMoreText(
                    tweetData.description,
                    style: TextStyle(
                        fontSize: isSinglePostView ? 16 : 15,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black
                    ),
                    trimLines: MAX_LINES_TO_SHOW,
                    colorClickableText: Colors.pink,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' Show less',
                    moreStyle: const TextStyle(
                        fontSize:  14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                    lessStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),


                  // =================== media display here ===================
                  // TODO: add video player and retweet
                  Visibility(
                    visible: (tweetData.media != null),
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
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 400),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: tweetData.mediaType == MediaType.VIDEO ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child:VideoPlayerWidget(videoUrl: tweetData.media!)
                            ) :
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(tweetData.media!,fit:BoxFit.fill),
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
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
                                  padding: EdgeInsets.symmetric(horizontal: 4,vertical: 15),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.grey
                              ),
                              child: Row(
                                children: [
                                  Text(
                                      "${tweetData.likesNum} ",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
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

        onPressed: () {
          Navigator.pushNamed(context, CreatePostPage.pageRoute , arguments: {
            "reply" : tweetData,
          });
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
          return toggleLikeTweet(userToken,tweetData.id);
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
      ["Add/remove from Lists", Icons.add, () {

      }], // ===============================================================
      ["Mute @${tweetOwner.id}", Icons.volume_off, () {
          // TODO: call the api to mute the post owner
      }], // ===============================================================
      ["Block @${tweetOwner.id}", Icons.block, () {
          // TODO: call the api to block the post owner
      }], // ===============================================================
    ];

    final upperRowNameField = isSinglePostView ?
    Row(
      children: [
        CircleAvatar(
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

        upperRowNameField,

        const Expanded(child: SizedBox()),

        Visibility(
          visible: isSinglePostView,
          child: SizedBox(
              height: 20,
              width: 80,
              // TODO: must be changed to whatever the current user state with this post owner
              child: FollowButton(
                  isFollowed: false, callBack: (bool followed) {})
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

class FollowButton extends StatefulWidget {
  bool isFollowed;
  void Function(bool) callBack;

  FollowButton({super.key, required this.isFollowed, required this.callBack});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeProvider.getInstance(context).isDark();
    return widget.isFollowed
        ? OutlinedButton(
            onPressed: () {
              // that user but for now i will assume it has successeded
              widget.isFollowed = false;
              widget.callBack(widget.isFollowed);
              setState(() {});
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15.0), // Set the border radius
              ),
              padding: const EdgeInsets.symmetric(vertical: -10.0),
            ),
            child: const Text(
              "Unfollow",
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ))
        : TextButton(
            onPressed: () {
              // TODO: we should send a request for the server and try to follow
              // that user but for now i will assume it has successeded
              widget.isFollowed = true;
              widget.callBack(widget.isFollowed);
              setState(() {});
            },
            style: TextButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.white : Colors.black,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15.0), // Set the border radius
              ),
              padding: const EdgeInsets.symmetric(vertical: -10.0),
            ),
            child: const Text(
              "Follow",
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ));
  }
}
