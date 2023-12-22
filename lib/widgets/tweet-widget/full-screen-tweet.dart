import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/Follow-Button.dart';
import 'package:gigachat/widgets/bottom-sheet.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:gigachat/widgets/tweet-widget/common-widgets.dart';
import 'package:gigachat/widgets/tweet-widget/tweet-controller.dart';
import 'package:gigachat/widgets/video-player.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatefulWidget {
  final double initialHeight = 200;
  static const String pageRoute = "/fullImage";
  const FullScreenImage({super.key});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}


class _FullScreenImageState extends State<FullScreenImage> {

  int? currentPage;
  double? height;
  late ValueNotifier upperValueNotifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    upperValueNotifier = ValueNotifier(0.0);
  }

  Future<void> _saveImage(String imageUrl) async {
    final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60
    );
    if (result["isSuccess"] == true && context.mounted){
      Toast.showToast(context, "image saved");
    }
  }

  List<Widget> buildList(List<MediaData> images){
    List<Widget> res = images.asMap().entries.map((entry) {
      int i = entry.key;
      MediaData image = entry.value;

      Widget photoView = image.mediaType == MediaType.VIDEO ?
          // TODO: handle the video later
      VideoPlayerWidget(
        videoUrl: image.mediaUrl,
        autoPlay: true,
        showControllers: true,
        tag: image.tag!,
      )
          :
      GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
              showDragHandle: true,
              context: context,
              builder: (context) => buildSheet(context, [
                ["Post Photo", Icons.add_circle_outline, () {
                  // TODO: send the image to the add new post page and navigate

                }],
                ["Save Photo", Icons.download, () {
                  // TODO: save the image to the device
                  _saveImage(image.mediaUrl);
                }]
              ]));
        },
        child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(image.mediaUrl)
        ),
      );

      return Center(
          child: i == currentPage ? Hero(
            tag: image.tag!,
            child: photoView,
          ) : photoView
      );
    }).toList();

    return res;
  }




  @override
  Widget build(BuildContext context) {

    Map<String,dynamic> argument = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    TweetData tweetData = argument["tweetData"];
    FeedController parentFeed = argument["parentFeed"];
    List<MediaData> images = tweetData.media!;
    currentPage ??= argument["index"];
    User currentUser = Auth.getInstance(context).getCurrentUser()!;

    return Scaffold(
        backgroundColor: Colors.black,
        body:
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 100),
              child: DismissiblePage(
                maxRadius: 0,
                minRadius: 0,
                isFullScreen: true,
                direction: DismissiblePageDismissDirection.vertical,
                dragSensitivity: 0.3,
                maxTransformValue: 0.1,

                onDragUpdate: (dragInfo){
                  upperValueNotifier.value = dragInfo.offset.distance * 1000;
                  setState(() {});
                },

                onDismissed: (){
                  Navigator.pop(context);
                },
                child: CarouselSlider(
                  options: CarouselOptions(
                      initialPage: currentPage!,
                      height: MediaQuery.of(context).size.height,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      aspectRatio: MediaQuery.of(context).size.aspectRatio,
                      onPageChanged: (int index, CarouselPageChangedReason reason){
                        currentPage = index;
                        setState(() {});
                      }
                  ),
                  items: buildList(images),
                ),
              ),
            ),


            Transform.translate(
              offset: Offset(0,upperValueNotifier.value * -1),
              child: ValueListenableBuilder(
                valueListenable:upperValueNotifier,
                builder: (context,_,__){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppBar(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(tweetData.tweetOwner.iconLink)),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tweetData.tweetOwner.name),
                              Text("@${tweetData.tweetOwner.id}",style: TextStyle(color: Colors.grey),)
                            ],
                          ),
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            width: 80,
                            height: 30,
                            child: FollowButton(
                              isFollowed: tweetData.tweetOwner.isFollowed!,
                              callBack: (_){},
                              username: tweetData.tweetOwner.id,
                            )
                          )
                        ],
                      ),

                    ],
                  );
                },
              ),
            ),

            Transform.translate(
              offset: Offset(0,upperValueNotifier.value),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                        children: initActionButtons(
                        context: context,
                        tweetData: tweetData,
                        singlePostView: false,
                        onCommentButtonClicked: () async {
                          return await commentTweet(context, tweetData,parentFeed);
                        },
                            onRetweetButtonClicked: () async {
                              bool isRetweeting = !tweetData.isRetweeted;
                              bool success =  await toggleRetweetTweet(currentUser.auth,tweetData);
                              if (!isRetweeting){
                                if(tweetData.tweetOwner.id == currentUser.id) {
                                  parentFeed.deleteTweet(tweetData.id);
                                  parentFeed.updateFeeds();
                                }
                                else {
                                  parentFeed.updateFeeds();
                                  setState(() {});
                                }
                              }
                              else{
                                parentFeed.updateFeeds();
                                setState(() {});();
                              }
                              return success;
                            },
                            onLikeButtonClicked: () async{
                              bool success =  await toggleLikeTweet(context,currentUser.auth,tweetData);
                              if (success){
                                parentFeed.updateFeeds();
                                setState(() {});
                              }
                              return success;
                            }
                        )
                    )
                  ],
                ),
              ),
            ),


          ],
        )

    );
  }
}
