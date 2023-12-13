import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'full-screen-tweet.dart';


class TweetMedia extends StatelessWidget {
  final List<MediaData> mediaList;

  TweetMedia({super.key, required this.mediaList});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: StaggeredGrid.count(
              crossAxisCount: mediaList.length > 1 ? 2 : 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              children: List.generate(mediaList.length, (index) => index)
              .map((index) {
                int mainCount = 1;
                int crossCount = 1;
                if (index == 0 && mediaList.length <= 3){
                  mainCount = mediaList.length > 1 ? 2 : 1;
                }
                if (index == 1 && mediaList.length == 2){
                  mainCount = 2;
                }
                return StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: imageEntity(context, index),
                );
              }).toList()
      ),
    );
  }


  Widget imageEntity(context, index){

    MediaData imageData = mediaList[index];

    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, FullScreenImage.pageRoute,
            arguments: {
              "image": mediaList,
              "index" : index
            });
      },
      child: Hero(
          tag: imageData.tag!,
          child:
          imageData.mediaType == MediaType.VIDEO ?
          SizedBox()
              :
          Image.network(imageData.mediaUrl,fit: BoxFit.fitWidth,)
      ),
    );

  }

}

