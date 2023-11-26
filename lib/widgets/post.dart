import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/services/input-formatting.dart';
import 'package:gigachat/util/tweet-data.dart';
import 'package:gigachat/widgets/bottom-sheet.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:readmore/readmore.dart';

class Tweet extends StatelessWidget {
  static String pageRoute = "/test";
  final User tweetOwner;
  final TweetData tweetData;
  late final List<Widget> actionButtons;
  bool? isRetweet;

  void initActionButtons(BuildContext context)
  {
    FeedProvider feedProvider = FeedProvider(context);
    actionButtons = [
      TweetActionButton(
        icon: FontAwesomeIcons.comment,
        count: 10000,
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
        count: 100,
        isLikeButton: false,
        isLiked: tweetData.isLiked!,
        onPressed: () {},
        isRetweet: true,
        isRetweeted: tweetData.isRetweeted,
        tweetId: tweetData.id,
      ),
      TweetActionButton(
          icon: FontAwesomeIcons.heart,
          count: 9998,
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
        count: 1000,
        onPressed: () {  },
        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,
      ),
      TweetActionButton(
          icon: Icons.share_outlined,
          isLikeButton: false,
          isLiked: tweetData.isLiked!,
          onPressed: () {  },
        isRetweet: false,
        isRetweeted: tweetData.isRetweeted,
      ),
    ];
  }

  Tweet({
    super.key,
    required this.tweetOwner,
    required this.tweetData,
    required this.isRetweet
  })
  {
    isRetweet ??= false;
  }

  void likeTweet() async{
    // TODO: call the interface here and send the tweet id to like it
    await Future.delayed(const Duration(seconds: 2));
    tweetData.isLiked = !tweetData.isLiked!;
    tweetData.likesNum += 1;
  }

  @override
  Widget build(BuildContext context) {
    initActionButtons(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(0)
      ),
      onPressed: (){
        //TODO: open the post page
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // user avatar
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(tweetOwner.iconLink)),
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
                  tweetUserInfo(context, tweetOwner, tweetData.creationTime),

                  // post content
                  // TODO: make the hashtags and mentions later
                  ReadMoreText(
                    tweetData.description,
                    trimLines: MAX_LINES_TO_SHOW,
                    colorClickableText: Colors.pink,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' Show less',
                    moreStyle: const TextStyle(fontSize: 14,color: Colors.blue, fontWeight: FontWeight.bold),
                    lessStyle: const TextStyle(fontSize: 14,color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  // media display here
                  Visibility(
                    visible: (tweetData.media != null && tweetData.mediaType == MediaType.IMAGE),
                    child: ElevatedButton(
                      onPressed: (){
                        // TODO: open full screen image
                      },
                      onLongPress: (){
                        showModalBottomSheet(
                          showDragHandle: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                          ),
                          context: context,
                          builder: (context) => buildSheet(context,
                              [
                                ["Post Photo",Icons.add_circle_outline,(){
                                    // TODO: send the image to the add new post page and navigate
                                }],
                                ["Save Photo",Icons.download,(){
                                    // TODO: save the image to the device
                                }]
                              ]
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(0)
                      ),
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
                        )
                      ),
                    ),
                  ),
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

  Widget tweetUserInfo(
      BuildContext context, User tweetOwner, DateTime tweetDate) {

    List<List> dotsBottomSheetData = [
      ["Not interested in ${tweetOwner.name}", Icons.cancel_outlined,(){
        // TODO: idk what to do fn
      }],
      ["Not interested in this post", FontAwesomeIcons.faceFrown,(){
        // TODO: idk what to do fn again
      }],
      [],
      ["Follow @${tweetOwner.id}", Icons.person_add_alt_1_outlined,(){
        // TODO: call the api to follow the post owner
      }],
      ["Add/remove from Lists", Icons.add,(){
        // TODO: idk fn
      }],
      ["Mute @${tweetOwner.id}", Icons.volume_off,(){
        // TODO: call the api to mute the post owner
      }],
      ["Block @${tweetOwner.id}", Icons.block,(){
        // TODO: call the api to block the post owner
      }],
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
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
        const Expanded(child: SizedBox()),
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
