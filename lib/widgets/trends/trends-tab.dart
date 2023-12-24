


import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/FeedWidget.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

class TrendsTab extends StatefulWidget {
  static String trendsFeedId = "TrendsFeed/";
  const TrendsTab({super.key});

  @override
  State<TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends State<TrendsTab> {
  late FeedController feedController;

  @override
  void initState() {
    super.initState();
    feedController = FeedProvider.getInstance(context).getFeedControllerById(
        context: context,
        id: TrendsTab.trendsFeedId,
        providerFunction: ProviderFunction.GET_TRENDS,
        clearData: true
    );
  }


  @override
  Widget build(BuildContext context) {
    return BetterFeed(
        removeController: false,
        removeRefreshIndicator: false,
        providerFunction: ProviderFunction.GET_TRENDS,
        providerResultType: ProviderResultType.TREND_RESULT,
        feedController: feedController
    );
  }
}
