import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/post-class.dart';
import 'package:gigachat/services/input-formatting.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';

class Tweet extends StatelessWidget {
  static String pageRoute = "/test";

  final User tweetOwner;
  final TweetData tweetData;
  late final List<Widget> actionButtons;
  bool? isRetweet;

  Tweet({super.key, required this.tweetOwner, required this.tweetData,required this.isRetweet}) {
    // TODO: we need to handle if the number is too big in the post provider processing
    isRetweet ??= false;
    actionButtons = [
      TweetActionButton(
        icon: FontAwesomeIcons.comment,
        count: 10000,
      ),
      TweetActionButton(
        icon: FontAwesomeIcons.retweet,
        count: 100,
      ),
      TweetActionButton(
          icon: FontAwesomeIcons.heart, count: 9998, isLikeButton: true),
      TweetActionButton(
        icon: Icons.bar_chart,
        count: 1000,
      ),
      TweetActionButton(icon: Icons.share_outlined, isShareButton: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // user avatar
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: CircleAvatar(
                radius: 20, backgroundImage: NetworkImage(tweetOwner.iconLink)),
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
                tweetUserInfo(context, tweetOwner, tweetData.date),

                // post content
                // TODO: make the hashtags and mentions later
                // TODO: trim the content if it was so big
                Text(tweetData.description),
                // media display here
                Visibility(
                  // TODO: visibility should be triggered if the post has some media
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(tweetData.media),
                    )
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: actionButtons
                          .map((actionBtn) => Flexible(child: actionBtn))
                          .toList()),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget tweetUserInfo(
      BuildContext context, User tweetOwner, DateTime tweetDate) {
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
              showBottomSheet(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                ),
                  context: context,
                  builder: (context) => buildSheet(context, tweetOwner),
              );
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

  Widget buildSheet(BuildContext context,User tweetOwner) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0,40,0,0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            modalSheetButton("Not interested in bla bla bla", Icons.cancel_outlined),
            modalSheetButton("Not interested in this post", FontAwesomeIcons.faceFrown),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: const Divider(color: Colors.white,height: 3)
            ),
            modalSheetButton("Follow @${tweetOwner.id}", Icons.person_add_alt_1_outlined),
            modalSheetButton("Add/remove from Lists", Icons.add),
            modalSheetButton("Mute @${tweetOwner.id}", Icons.volume_off),
            modalSheetButton("Block @${tweetOwner.id}", Icons.block),
          ],
        ),
      ),
    );
  }


  Widget modalSheetButton(String content, IconData icon)
  {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(15)
      ),
      onPressed: () {},
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10,),
          Expanded(child: Text(content,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w400),),),
        ],
      ),
    );
  }
}
