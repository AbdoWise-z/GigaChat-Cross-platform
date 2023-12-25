import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/user-class.dart';

class PostStaticViewer extends StatefulWidget {
  final TweetData tweet;

  const PostStaticViewer({
    super.key,
    required this.tweet,
  });

  @override
  State<PostStaticViewer> createState() => PostStaticViewerState();
}

class PostStaticViewerState extends State<PostStaticViewer> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }
  //TODO: @yuki revise this
  Widget _getImageWidget(){
    if (widget.tweet.media == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          widget.tweet.media![0].mediaUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User user = widget.tweet.tweetOwner;
    double width = MediaQuery.of(context).size.width;

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Icon column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(user.iconLink),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    border: Border.all(
                      width: 0,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: VerticalDivider(
                  width: 10,
                  thickness: 2,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          //Content
          Padding(
            padding: const EdgeInsets.only(top: 4 , left: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width - 40 - 8 * 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0 , right: 8.0),
                        child: Text(
                          "${user.id}",
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: width - 40 - 8 * 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.tweet.description,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _getImageWidget(),
                    ],
                  ),
                ),
                const Text(""), //just a "\n"

                SizedBox(
                  width: width - 40 - 8 * 2,
                  child: Row(
                    children: [
                      const Text(
                        "Replying to ",
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),
                      ),

                      Text(
                        user.id,
                        softWrap: true,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
