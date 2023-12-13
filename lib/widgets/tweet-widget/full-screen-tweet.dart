import 'package:carousel_slider/carousel_slider.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

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

  List<Widget> buildList(List<MediaData> images){
    List<Widget> res = images.asMap().entries.map((entry) {
      int i = entry.key;
      MediaData image = entry.value;

      Widget photoView = image.mediaType == MediaType.VIDEO ?
          // TODO: handle the video later
      const SizedBox()
          :
      PhotoView(
          minScale: PhotoViewComputedScale.contained,
          imageProvider: NetworkImage(image.mediaUrl)
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
    List<MediaData> images = argument["image"];
    currentPage ??= argument["index"];

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
                  return Container(
                    height: 100,
                    alignment: Alignment.bottomCenter,
                    color: Colors.blue,
                    child: Text("TESTING"),
                  );
                },
              ),
            ),

            Transform.translate(
              offset: Offset(0,upperValueNotifier.value),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ),


          ],
        )

    );
  }
}
