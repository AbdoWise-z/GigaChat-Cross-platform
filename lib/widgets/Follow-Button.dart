
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

class FollowButton extends StatefulWidget {
  bool isFollowed;
  String username;
  void Function(bool) callBack;

  FollowButton({
    super.key,
    required this.isFollowed,
    required this.callBack,
    required this.username
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}


class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeProvider.getInstance(context).isDark();
    return widget.isFollowed
        ? OutlinedButton(
        onPressed: () async {
          await Auth.getInstance(context).unfollow(
              widget.username,
            success: (res){
              widget.isFollowed = false;
              widget.callBack(false);
              FeedController homeFeed = FeedProvider.getInstance(context).getFeedControllerById(
                  context: context,
                  id: Home.feedID,
                  providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
                  clearData: false
              );
              homeFeed.resetFeed();
              homeFeed.updateFeeds();
              setState(() {});
            },
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(15.0), // Set the border radius
          ),
        ),
        child: const Text(
          "Unfollow",
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ))
        : TextButton(
        onPressed: () async {
          // TODO: we should send a request for the server and try to follow
          // that user but for now i will assume it has successeded
          await Auth.getInstance(context).follow(
            widget.username,
            success: (res){
              widget.isFollowed = true;
              widget.callBack(true);
              FeedController homeFeed = FeedProvider.getInstance(context).getFeedControllerById(
                  context: context,
                  id: Home.feedID,
                  providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
                  clearData: false
              );
              homeFeed.resetFeed();
              homeFeed.updateFeeds();
              setState(() {});
            },
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.only(top: -10),
          backgroundColor: isDarkMode ? Colors.white : Colors.black,
          foregroundColor: isDarkMode ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(15.0), // Set the border radius
          ),
        ),
        child: const Text(
          "Follow",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ));
  }
}
