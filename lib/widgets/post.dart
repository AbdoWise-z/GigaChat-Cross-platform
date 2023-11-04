import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/post-class.dart';
import 'package:gigachat/services/input-formatting.dart';
import 'package:gigachat/widgets/feed-component/tweetActionButton.dart';

class Tweet extends StatelessWidget {
  static String pageRoute = "/test";

  final User tweetOwner;
  final TweetData tweetData;
  late final List<TweetActionButton> actionButtons;

  Tweet({super.key, required this.tweetOwner, required this.tweetData})
  {
    actionButtons = [
      TweetActionButton(icon: FontAwesomeIcons.comment,count: 100,),
      TweetActionButton(icon: FontAwesomeIcons.retweet,count: 100,),
      TweetActionButton(icon: FontAwesomeIcons.heart,count: 100,),
      TweetActionButton(icon: Icons.bar_chart,count: 100,),
      TweetActionButton(icon: Icons.share_outlined),
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
                tweetUserInfo(tweetOwner, tweetData.date),

                // post content
                // TODO: make the hashtags and mentions later
                // TODO: trim the content if it was so big
                Text(tweetData.description),
                // media display here
                Visibility(
                  // TODO: visibility should be triggered if the post has some media
                  visible: true,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(tweetData.media)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                    children:actionButtons.map
                      ((actionBtn) => Flexible(child: actionBtn)).toList())
              ],
            ),
          )
        ],
      ),
    );
  }
}


Widget tweetUserInfo(User tweetOwner, DateTime tweetDate) {
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
                text: " . ${InputFormatting.calculateDateSincePost(tweetDate)}")
          ])),
      const Expanded(child: SizedBox()),
      SizedBox(
        height: 30,
        width: 30,
        child: IconButton(
          onPressed: () {
            //TODO: implement the button menu
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
