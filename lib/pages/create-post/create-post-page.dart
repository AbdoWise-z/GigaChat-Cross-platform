import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/create-post/widgets/hint-dialog.dart';
import 'package:gigachat/pages/create-post/widgets/post-editor.dart';
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


  GlobalKey<PostEditorState>? _currentActive;

  final List<GlobalKey<PostEditorState>> _posts = [];

  @override
  void initState() {
    super.initState();
    nodes.add(FocusNode());
    _posts.add(GlobalKey<PostEditorState>());
    _currentActive = _posts[0];
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

    print("update");

    return Scaffold(
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
                  //TODO: do post ..
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
    );
  }
}
