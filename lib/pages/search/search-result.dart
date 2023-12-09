import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

class SearchResultPage extends StatefulWidget {
  static const String pageRoute = "/search/result";
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late FeedController latestFeedController;
  late FeedController userFeedController;

  @override
  void initState() {
    latestFeedController = FeedController(providerFunction: ProviderFunction.HOME_PAGE_TWEETS);
    userFeedController = FeedController(providerFunction: ProviderFunction.SEARCH_USERS);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    latestFeedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    userFeedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);
    Map<String,dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    String keyword = arguments["keyword"];
    print(keyword);
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              Expanded(child: FilledButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  alignment: Alignment.centerLeft,
                ),
                child: Text(keyword),

              )),
              IconButton(
                  onPressed: (){},
                  splashRadius: 20,
                  icon: const Icon(FontAwesomeIcons.sliders,size: 20,)
              ),
              IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.more_vert,size: 20,)
              ),

            ],
          ),
          bottom: const TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: "Top"),
              Tab(text: "Users"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            BetterFeed(
                isScrollable: true,
                providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
                providerResultType: ProviderResultType.TWEET_RESULT,
                feedController: latestFeedController
            ),
            BetterFeed(
                isScrollable: true,
                providerFunction: ProviderFunction.SEARCH_USERS,
                providerResultType: ProviderResultType.USER_RESULT,
                feedController: userFeedController,
                keyword: keyword,
            ),
          ],
        ),
      ),
    );
  }
}
