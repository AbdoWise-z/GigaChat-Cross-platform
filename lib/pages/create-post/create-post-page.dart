import 'package:flutter/material.dart';
import 'package:gigachat/api/tweet-data.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/create-post/widgets/hint-dialog.dart';
import 'package:gigachat/pages/create-post/widgets/post-editor.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/gallery/gallery.dart';

class CreatePostPage extends StatefulWidget {
  static const String pageRoute = "/create-post";
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {

  List<FocusNode> nodes = [];

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

    Auth auth = Auth.getInstance(context);
    FeedProvider feed = FeedProvider(context);

    String? ref;
    bool error = false;
    for (var k in _posts){
      var state = k.currentState!;
      IntermediateTweetData data = IntermediateTweetData(
        description: state.controller.text,
        media: state.media.map((e) => MediaObject(
          //TODO : replace with the actual media
          link: "https://i.imgur.com/9XSC9YB.jpeg",
          type: MediaType.IMAGE,
        )).toList(growable: false),
        referredTweetId: ref,
        type: ref == null ? TweetType.TWEET : TweetType.REPLY,
      );
      if (!await feed.sendTweet(
        auth.getCurrentUser()!,
        data ,
        success: (v) => ref = v.data!,
        error: (v) => print(v.responseBody),
      )) {
        if (ref != null){
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



    //TODO: add the return result if needed
    if (!context.mounted) return;
    if (!error) Navigator.pop(context);
    setState(() {
      _loading = false;
    });

  }

  GlobalKey<PostEditorState>? _currentActive;
  bool _loading = false;

  final List<GlobalKey<PostEditorState>> _posts = [];

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

    nodes.add(FocusNode());
    _posts.add(GlobalKey<PostEditorState>());
    _currentActive = _posts[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                          return HintDialog();
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
                SizedBox(width: 15,),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      _sendTweets();
                    },
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(Colors.blue)
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
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...
                      _posts.map(
                            (e) => PostEditor(
                          key: e,
                          maxImageHeight: _posts.length == 1 ? 0 : 1,
                          active: _currentActive == e,
                          multi: e != _posts.last,
                          muteable: _posts.length > 1,
                          onFocus: (v) {
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
                    ],
                  ),
                ),
              ),
              const Divider(
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
                        List<String> items = state.media;
                        var selected = await Gallery.selectFromGallery(context , selected: items);
                        state.setState(() {
                          state.media = selected; //totally crashable btw
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
                        value: _currentActive != null && _currentActive!.currentState != null ? (_currentActive!.currentState!.controller.text.length / MAX_POST_LENGTH) : 0,
                      ),
                    ),

                    IconButton(
                      onPressed: canAddAnother ? () {
                        setState(() {
                          var k = GlobalKey<PostEditorState>();
                          _posts.insert(_posts.indexOf(_currentActive!) + 1, k);
                        });
                      } : null,
                      icon: const Icon(Icons.add_circle) ,
                      color: Colors.blue,
                    ),

                    const SizedBox(width: 5,),
                  ],
                ),
              )
            ],
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
