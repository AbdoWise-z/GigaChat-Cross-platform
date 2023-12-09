import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/widgets/gallery/gallery.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class PostMediaView extends StatefulWidget {
  final TypedEntity media;
  final double width;
  const PostMediaView({super.key, required this.media, required this.width});

  @override
  State<PostMediaView> createState() => _PostMediaViewState();
}

class _PostMediaViewState extends State<PostMediaView> {
  late final VideoPlayerController _controller;
  final GlobalKey _key = GlobalKey();
  double _ratio  = 1;
  bool _playing = false;

  void _initController() async {
    if (widget.media.type == AssetType.image) return;
    await _controller.initialize();
    //await _controller.play();
    _controller.addListener(() {
      if (_controller.value.isPlaying){
        if (!_playing){
          setState(() {
            _playing = true;
          });
        }
      }else{
        if (_playing){
          setState(() {
            _playing = false;
          });
        }
      }
    });

    _ratio = _controller.value.size.height / _controller.value.size.width;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


  @override
  void initState() {
    _controller = VideoPlayerController.file(
      widget.media.path,
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
      ),
    );
    _initController();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return widget.media.type == AssetType.image ? Container(
      constraints: BoxConstraints(maxWidth: widget.width),
      child: Image.file(
        File(widget.media.path.path),
        fit: BoxFit.cover,
      ),
    ) : SizedBox(
      key: _key,
      width: double.infinity,
      height: widget.width * _ratio,
      child: FlickVideoPlayer(
        flickManager: FlickManager(
            videoPlayerController: _controller
        ),
      ),
    );
  }
}
