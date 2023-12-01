import 'package:flutter/material.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/tweet-widget/tweet.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum UserListViewFunction{
  GET_TWEET_LIKERS,
  GET_TWEET_REPOSTERS
}

class UserListViewPage extends StatefulWidget {
  static const pageRoute = "/list-view";
  UserListViewFunction? providerType;
  late String pageTitle;
  late String tweetID;

  UserListViewPage({super.key,this.providerType});

  @override
  State<UserListViewPage> createState() => _UserListViewPageState();
}

class _UserListViewPageState extends State<UserListViewPage> {

  void fetchUsers(String userToken, String tweetID, int page) async {

    switch (widget.providerType){
      case UserListViewFunction.GET_TWEET_LIKERS:
        currentList = await Tweets.getTweetLikers(userToken,tweetID,page.toString());
      case UserListViewFunction.GET_TWEET_REPOSTERS:
        currentList = await Tweets.getTweetLikers(userToken, tweetID, page.toString());
      case null:
        currentList = [];
    }
    loading = false;
    if(mounted) setState(() {});
  }

  List<Widget> wrapUsersInWidget(List<User> users,String userToken, String tweetID,{required bool isDarkMode}){
    return users.asMap().entries.map((user) => TextButton(
      onPressed: (){},
      style: TextButton.styleFrom(

      ),
      child: VisibilityDetector(
        onVisibilityChanged: (VisibilityInfo info){
          if (info.visibleFraction * 100 > 50 && (user.key + 1) % DEFAULT_PAGE_COUNT == 0){
            fetchUsers(userToken, tweetID, ((user.key + 1) ~/ DEFAULT_PAGE_COUNT) + 1);
          }
        },
        key: Key(user.value.id),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.value.iconLink),
              ),
              const SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.value.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16
                    ),
                  ),
                  Text("@${user.value.id}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.grey
                    ),
                  ),
                  Text(user.value.bio,style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,))
                ],
              ),
              const Expanded(child: SizedBox()),
              SizedBox(
                  width: 100,
                  height: 25,
                  child: FollowButton(isFollowed: false, callBack: (bool followed){})
              ),
            ],
          ),
        ),
      ),
    )
    ).toList();
  }

  late List<User> currentList;
  late int lastRequestedPage;
  late bool loading;

  @override
  void initState() {
    super.initState();
    currentList = [];
    lastRequestedPage = 0;
    loading = true;
  }

  @override
  Widget build(BuildContext context) {
    Map<String,dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    widget.pageTitle = args["pageTitle"];
    widget.tweetID = args["tweetID"];
    widget.providerType = args["providerType"];

    bool isDarkMode = ThemeProvider.getInstance(context).isDark();
    String userToken = Auth.getInstance(context).getCurrentUser()!.auth!;

    if(loading){
      fetchUsers(userToken, widget.tweetID, 1);
      return LoadingPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle,style: const TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: wrapUsersInWidget(currentList,userToken,widget.tweetID, isDarkMode: isDarkMode),
        ),
      ),
    );
  }
}


