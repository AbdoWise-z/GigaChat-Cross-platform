import 'package:flutter/material.dart';
import 'package:gigachat/pages/create-post/widgets/hint-dialog.dart';
import 'package:gigachat/widgets/gallery/gallery.dart';

class CreatePostPage extends StatefulWidget {
  static const String pageRoute = "/create-post";
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
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

  String selected = "";

  void _loadGallery() async {
    var s = await Gallery.selectFromGallery(context);
    selected = "$s";
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: () => _openDialog(), child: Text("open")),
          ElevatedButton(onPressed: () => _loadGallery(), child: Text("Gallery")),
          Text(selected),
        ],
      ),
    );
  }
}
