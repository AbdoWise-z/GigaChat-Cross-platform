
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/media-class.dart';
import 'package:gigachat/api/media-requests.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/create-post/widgets/hint-dialog.dart';
import 'package:gigachat/pages/create-post/widgets/post-editor.dart';
import 'package:gigachat/pages/create-post/widgets/post-static-viewer.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/gallery/gallery.dart';
import 'package:photo_manager/photo_manager.dart';


///
/// This page is responsible of creating a widget to allow the user to create a new post
/// or to add a reply on a created post , it takes one parameter [reply] which is the Tweet to reply to
/// if this parameter is null, then it starts creating a new tweet
///
class CreatePostPage extends StatefulWidget {
  static const String pageRoute = "/create-post";
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}


Future<bool> sendTweet(User from , IntermediateTweetData data , {
  void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
  var res = await Tweets.apiSendTweet(from.auth! , data);
  if (res.data != null){
    if (success != null) success(res);
    return true;
  }else{
    if (error != null) error(res);
    return false;
  }
}

class _CreatePostPageState extends State<CreatePostPage> {
  void _openDialog(){
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx , _ , __) => const HintDialog(),
        opaque: false,
        transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child){
          return FadeTransition(opacity: animation , child: child,);
        },
        transitionDuration: const Duration(milliseconds: 100),
        reverseTransitionDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  void _sendTweets() async {
    // if (_posts.length > 1){
    //   Toast.showToast(context, "We currently support only one tweet");
    //   return;
    // }

    setState(() {
      _loading = true;
    });
    List<TweetData> returnList = [];

    for (var k in _posts){
      if (k.currentState!.controller.text.isEmpty && k.currentState!.media.isEmpty){
        Toast.showToast(context, "post cannot be empty");
        setState(() {
          _loading = false;
        });
        return;
      }
    }

    Auth auth = Auth.getInstance(context);

    String? ref;
    if (_replyTweet != null) {
      ref = _replyTweet!.id;
    }

    bool error = false;
    for (var k in _posts){
      var state = k.currentState!;
      List<TypedEntity> paths = state.media;
      List<UploadFile> files = paths.map(
              (e) => UploadFile(
                path: e.path.path,
                type: e.type == AssetType.image ? "image" : "video",
                subtype: e.type == AssetType.image ? "png" : "mp4"
              )
      ).toList();

      ApiResponse<List> response = await Media.uploadMedia(auth.getCurrentUser()!.auth!, files);

      if (response.data == null || response.data!.length != paths.length){
        if (!context.mounted) return; //just to make flutter shut up
        Toast.showToast(context, "Please check your internet");
        error = true;
        break;
      }

      List urls = response.data!;

      IntermediateTweetData data = IntermediateTweetData(
        description: state.controller.text,
        media: files.map((e) => MediaObject(
          link: urls[files.indexOf(e)],
          type: e.type == "video" ? MediaType.VIDEO : MediaType.IMAGE,
        )).toList(growable: false),
        referredTweetId: ref,
        type: ref == null ? TweetType.TWEET : TweetType.REPLY,
      );

      if (!await sendTweet(
        auth.getCurrentUser()!,
        data ,
        success: (v) {
          ref = v.data!;
          auth.getCurrentUser()!.numOfPosts++;
          TweetData tweetData = TweetData(
              id: ref!,
              referredTweetId: data.referredTweetId,
              description: data.description,
              viewsNum: 0,
              likesNum: 0,
              repliesNum: 0,
              repostsNum: 0,
              creationTime: DateTime.now(),
              type: data.referredTweetId == null ? "tweet" : "reply",
              tweetOwner: auth.getCurrentUser()!,
              isLiked: false,
              isRetweeted: false,
              isFollowingMe: false,
              media: data.media.isEmpty ? null :
              data.media.map((e) => MediaData(mediaType: e.type, mediaUrl: e.link)).toList(),
              replyingUserId: _replyTweet == null ? null : _replyTweet!.tweetOwner.id
          );
          returnList.add(tweetData);
          if (_replyTweet != null) {
            _replyTweet!.replyTweet = tweetData;
          }
        } ,
        error: (v) => print(v.responseBody),
      )) {
        if (ref != null && _replyTweet == null){
          //well .. this is bad ..
          if (!context.mounted) return; //just to make flutter shut up
          Toast.showToast(context, "API ERROR");
          Navigator.pop(context);
          return;
        } else {
          //the first tweet wasn't sent ..
          if (!context.mounted) return; //just to make flutter shut up
          Toast.showToast(context, "Please check your internet");
          error = true;
          break;
        }
      }
    }

    if (!context.mounted) return;
    if (!error) Navigator.pop(context,{"success":true, "tweets" : returnList});

    setState(() {
      _loading = false;
    });
  }


  GlobalKey<PostEditorState>? _currentActive;
  final GlobalKey _scrollerKey = GlobalKey();
  final GlobalKey _PostKey     = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  bool _loading = false;

  final List<GlobalKey<PostEditorState>> _posts = [];
  TweetData? _replyTweet;

  double _bottomBoxHeight = 0;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();


    Future.delayed(Duration.zero , () {
      LocalSettings locals = LocalSettings.getInstance(context);
      if (locals.getValue<bool>(name: "first_post", def: true)!){ //view this pop up only in the first post
        _openDialog();
        locals.setValue(name: "first_post", val: false);
        locals.apply();
      }
    });

    _posts.add(GlobalKey<PostEditorState>());
    _currentActive = _posts[0];

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (_replyTweet != null){
        final k = _posts[0].currentContext!.size!;
        //print("got size ${k.height}");
        setState(() {
          _bottomBoxHeight = _scrollerKey.currentContext!.size!.height - k.height - 20;
        });
      }
    });
  }

  double _abs(double k){
    if (k > 0) return k;
    return -k;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    bool canPost = true;
    for (var k in _posts){
      if (k.currentState != null
          && ((k.currentState!.controller.text.isEmpty && k.currentState!.media.isEmpty) || k.currentState!.controller.text.length > MAX_POST_LENGTH)){
        canPost = false;
        break;
      }
    }

    if (_replyTweet == null) {
      if (ModalRoute
          .of(context)!
          .settings
          .arguments != null) {
        var params = ModalRoute
            .of(context)!
            .settings
            .arguments as Map;
        _replyTweet = params["reply"];
      }
    }

    bool canAddAnother = _currentActive != null;
    for (var k in _posts){
      if (k.currentState == null) {
        canAddAnother = false;
      } else if (k.currentState!.controller.text.isEmpty) {
        canAddAnother = false;
      }
    }

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () { Navigator.pop(context , {}); },
            ),
            title: Row(
              children: [
                const Expanded(child: SizedBox()),
                Visibility(
                  visible: false, //for debug only
                  child: SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                            return const HintDialog();
                          },
                        ));
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(Colors.blue)
                      ),
                      child: const Text(
                        "Test",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15,),

                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: canPost ? () {
                      _sendTweets();
                    } : null,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.any((element) => element == MaterialState.disabled)){
                          return Colors.blueAccent.withAlpha(120);
                        }
                        return Colors.blueAccent;
                      }),
                    ),
                    child: Text(
                      _posts.length > 1 ? "Post all" : "Post",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
          body: LayoutBuilder(
            builder: (context , bc) {

              if (_replyTweet != null) {
                Future.delayed(Duration.zero, () {
                  double h = _posts[0].currentContext!.size!.height;
                  if (_bottomBoxHeight !=
                      _scrollerKey.currentContext!.size!.height - h - 20) {
                    _bottomBoxHeight =
                        _scrollerKey.currentContext!.size!.height - h - 20;
                    if (_bottomBoxHeight < 0) {
                      _bottomBoxHeight = 0;
                    }
                    setState(() {});
                  }

                  if (_hasFocus) {
                    if (_bottomBoxHeight > 0) {
                      _scrollController.animateTo(
                        _PostKey.currentContext!.size!.height - 20,
                        duration: Duration(
                          milliseconds: _abs(
                              (_PostKey.currentContext!.size!.height - 20 -
                                  _scrollController.offset) / 2
                          ).toInt(),
                        ),
                        curve: Curves.easeIn,
                      );
                    }
                  }
                });
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: _scrollerKey,
                      controller: _scrollController,
                      child: Column(
                        children: [
                          (_replyTweet != null) ?
                          PostStaticViewer(
                            key: _PostKey,
                            tweet: _replyTweet!,
                          )
                              :
                          const SizedBox.shrink(),
                          ...
                          _posts.map(
                                (e) => PostEditor(
                              key: e,
                              maxImageHeight: _posts.length == 1 ? 0 : 1,
                              active: _currentActive == e,
                              multi: e != _posts.last,
                              muteable: _posts.length > 1,
                              onFocus: (v) {
                                _hasFocus = v;
                                setState(() {
                                  if (v) {
                                    _currentActive = e;
                                  } else if (_currentActive == e){
                                    _currentActive = null;
                                  }
                                });

                              },
                              onRemove: () {
                                setState(() {
                                  _posts.remove(e);
                                });
                              },
                              onTextChanged: () => setState(() {}),
                            ) ,
                          ),

                          SizedBox(
                            //child: Placeholder(),
                            height: _bottomBoxHeight,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.blueGrey,
                  ),

                  SizedBox(
                    height: 50,
                    width: null,
                    child: Row(
                      children: [
                        const SizedBox(width: 5,),

                        IconButton(
                          onPressed: _currentActive != null ? () async {
                            var state = _currentActive!.currentState!;
                            //if you somehow was able to click before the app even builds
                            //then you deserve the app crash in your face :)
                            List<TypedEntity> items = state.media;
                            var selected = await Gallery.selectFromGallery(context , selected: items.map((e) => e.path).toList() , canSkip: true);
                            state.setState(() {
                              state.media = selected.map((e) => TypedEntity(path: e.path, type: e.type == AssetType.other ? items[items.indexWhere((element) => e.path.path == element.path.path)].type : e.type)).toList();
                            });

                          } : null,
                          icon: const Icon(Icons.photo_outlined) ,
                          color: Colors.blue,
                        ),

                        const Expanded(child: SizedBox()),

                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.grey,
                            strokeWidth: 2,
                            valueColor: _currentActive != null && (_currentActive!.currentState != null &&
                                _currentActive!.currentState!.controller.text.length > MAX_POST_LENGTH) ? const AlwaysStoppedAnimation(Colors.red) :
                            const AlwaysStoppedAnimation(Colors.blue),
                            value: _currentActive != null && _currentActive!.currentState != null ? (_currentActive!.currentState!.controller.text.length / MAX_POST_LENGTH) : 0,
                          ),
                        ),

                        Visibility(
                          visible: _replyTweet == null,
                          child: IconButton(
                            onPressed: canAddAnother ? () {
                              setState(() {
                                var k = GlobalKey<PostEditorState>();
                                _posts.insert(_posts.indexOf(_currentActive!) + 1, k);
                              });
                            } : null,
                            icon: const Icon(Icons.add_circle) ,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 5,),
                      ],
                    ),
                  )
                ],
              );
            }
          ),
        ),
        Visibility(
          visible: _loading,
          child: const BlockingLoadingPage(),
        ),
      ],
    );
  }
}
