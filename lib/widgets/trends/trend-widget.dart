

import 'package:flutter/material.dart';
import 'package:gigachat/api/trend-data.dart';
import 'package:gigachat/pages/search/search-result.dart';

class TrendWidget extends StatelessWidget {
  final TrendData trendData;
  const TrendWidget({super.key, required this.trendData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
          Navigator.pushNamed(
              context, SearchResultPage.pageRoute, arguments: {
            "keyword": trendData.trendContent
          });
          },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Trending in Egypt",style: TextStyle(color: Colors.grey,fontSize: 15)),
                Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 5,),
            Text(trendData.trendContent,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
            const SizedBox(height: 5,),
            Text("${trendData.numberOfPosts.toString()} posts",style: const TextStyle(color: Colors.grey,fontSize: 15))
          ],
        ),
      ),
    );
  }
}
