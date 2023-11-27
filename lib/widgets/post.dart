import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/services/input-formatting.dart';
import 'package:gigachat/util/tweet-data.dart';
import 'package:gigachat/widgets/bottom-sheet.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class Tweet extends StatelessWidget {
  static String pageRoute = "/test";
  final User tweetOwner;
  final TweetData tweetData;
  late List<Widget> actionButtons;
  final bool isRetweet;
  final bool isSinglePostView;

  Tweet(
      {super.key,
      required this.tweetOwner,
      required this.tweetData,
      required this.isRetweet,
      required this.isSinglePostView});

  void likeTweet() async {
    // TODO: call the interface here and send the tweet id to like it
    await Future.delayed(const Duration(seconds: 2));
    tweetData.isLiked = !tweetData.isLiked;
    tweetData.likesNum += 1;
  }

  @override
  Widget build(BuildContext context) {
    initActionButtons(context, tweetData, isSinglePostView);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(0)),
      onPressed: isSinglePostView
          ? () {}
          : () {
              //TODO: open the post page
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
            // user avatar
            Visibility(
              visible: !isSinglePostView,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(tweetOwner.iconLink)),
              ),
            ),
            // some padding
            const SizedBox(width: 10),
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // post owner data
                  tweetUserInfo(context, tweetOwner, tweetData.creationTime,
                      isSinglePostView),

                  Visibility(
                      visible: isSinglePostView,
                      child: const SizedBox(height: 5)),

                  // post content
                  // TODO: make the hashtags and mentions later
                  ReadMoreText(
                    tweetData.description,
                    style: TextStyle(fontSize: isSinglePostView ? 16 : 15, fontWeight: FontWeight.w500),
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
                  // media display here
                  Visibility(
                    visible: (tweetData.media != null &&
                        tweetData.mediaType == MediaType.IMAGE),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: open full screen image
                      },
                      onLongPress: () {
                        showModalBottomSheet(
                          showDragHandle: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20))),
                          context: context,
                          builder: (context) => buildSheet(context, [
                            [
                              "Post Photo",
                              Icons.add_circle_outline,
                              () {
                                // TODO: send the image to the add new post page and navigate
                              }
                            ],
                            [
                              "Save Photo",
                              Icons.download,
                              () {
                                // TODO: save the image to the device
                              }
                            ]
                          ]),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(0)),
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 400),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(tweetData.media!),
                          )),
                    ),
                  ),

                  Visibility(
                      visible: isSinglePostView,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: RichText(
                              text: TextSpan(
                                  text: DateFormat("hh:mm a . d MMMM yy . ")
                                      .format(tweetData.creationTime),
                                  style: const TextStyle(color: Colors.grey),
                                  children: [
                                    TextSpan(
                                        text: NumberFormat.compact()
                                            .format(tweetData.viewsNum),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    const TextSpan(text: " Views")
                                  ]),
                            ),
                          )
                        ],
                      )),

                  Visibility(visible: isSinglePostView, child: const Divider(thickness: 2,height: 10)),

                  Visibility(
                      visible: isSinglePostView,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: RichText(
                              text: TextSpan(
                                  text: tweetData.repostsNum.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  children: [
                                    const TextSpan(
                                        text: " Reposts ",
                                        style: TextStyle(color: Colors.grey)
                                    ),
                                    TextSpan(text: tweetData.likesNum.toString()),
                                    const TextSpan(
                                        text: " Likes ",
                                        style: TextStyle(color: Colors.grey)
                                    )
                                  ]),
                            ),
                          )
                        ],
                      )),

                  Visibility(visible: isSinglePostView, child: const Divider(thickness: 2,height: 10)),


                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: actionButtons
                            .map((actionBtn) => actionBtn)
                            .toList()),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }



  void initActionButtons(
      BuildContext context, TweetData tweetData, bool singlePostView) {
    FeedProvider feedProvider = FeedProvider(context);
    actionButtons = [
      TweetActionButton(
        icon: FontAwesomeIcons.comment,
        count: singlePostView ? null : tweetData.repliesNum,
        isLikeButton: false,
        isRetweet: false,
        isRetweeted: false,
        isLiked: tweetData.isLiked!,
        onPressed: () {
          // TODO: navigate to the add post page in comment mode and send it [username, post id]
        },
      ),
      TweetActionButton(
        icon: FontAwesomeIcons.retweet,
        count: singlePostView ? null : tweetData.repostsNum,
        isLikeButton: false,
        isLiked: tweetData.isLiked!,
        onPressed: () {},
        isRetweet: true,
        isRetweeted: tweetData.isRetweeted,
        tweetId: tweetData.id,
      ),
      TweetActionButton(
        icon: FontAwesomeIcons.heart,
        count: singlePostView ? null : tweetData.likesNum,
        isLikeButton: true,
        isLiked: tweetData.isLiked!,
        onPressed: likeTweet,
        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,
      ),
      TweetActionButton(
        icon: Icons.bar_chart,
        isLikeButton: false,
        isLiked: tweetData.isLiked!,
        count: singlePostView ? null : tweetData.viewsNum,
        onPressed: () {},
        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,
      ),
      TweetActionButton(
        icon: Icons.share_outlined,
        isLikeButton: false,
        isLiked: tweetData.isLiked!,
        onPressed: () {},
        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,
      ),
    ];
  }

  Widget tweetUserInfo(BuildContext context, User tweetOwner,
      DateTime tweetDate, bool isSignlePostView) {
    List<List> dotsBottomSheetData = [
      [
        "Not interested in ${tweetOwner.name}",
        Icons.cancel_outlined,
        () {
          // TODO: idk what to do fn
        }
      ],
      [
        "Not interested in this post",
        FontAwesomeIcons.faceFrown,
        () {
          // TODO: idk what to do fn again
        }
      ],
      [],
      [
        "Follow @${tweetOwner.id}",
        Icons.person_add_alt_1_outlined,
        () {
          // TODO: call the api to follow the post owner
        }
      ],
      [
        "Add/remove from Lists",
        Icons.add,
        () {
          // TODO: idk fn
        }
      ],
      [
        "Mute @${tweetOwner.id}",
        Icons.volume_off,
        () {
          // TODO: call the api to mute the post owner
        }
      ],
      [
        "Block @${tweetOwner.id}",
        Icons.block,
        () {
          // TODO: call the api to block the post owner
        }
      ],
    ];

    final upperRowNameField = isSinglePostView
        ? Row(
            children: [
              CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(tweetOwner.iconLink)),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tweetOwner.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("@${tweetOwner.id}",
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w400))
                ],
              ),
            ],
          )
        : Row(
            children: [
              Text(tweetOwner.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
          visible: isSignlePostView,
          child: SizedBox(
              height: 20,
              width: 80,
              // TODO: must be changed to whatever the current user state with this post owner
              child: FollowButton(
                  isFollowed: false, callBack: (bool followed) {})),
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
              "Follow",
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
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
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
