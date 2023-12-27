import 'dart:math';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Video Player For The Chat Page
/// [url] url path to the video to be shown
/// [maxWidth] maximum container width for the player
class ChatVideoPlayer extends StatefulWidget {
  final String url;
  final double maxWidth;
  const ChatVideoPlayer({super.key, required this.url, required this.maxWidth});

  @override
  State<ChatVideoPlayer> createState() => _ChatVideoPlayerState();
}

class _ChatVideoPlayerState extends State<ChatVideoPlayer> {
  late final VideoController _controller;
  late final Player _player;
  final GlobalKey _key = GlobalKey();

  double width = -1;
  double height = -1;

  void _initController() async {
    _player.stream.error.listen((event) {
      print(event);
    });
    _player.stream.width.listen((event) {
      if (event == null){
        print("Error with video width");
        width = -1;
      }else {
        width = event.toDouble();
      }
      setState(() {

      });
    });

    _player.stream.height.listen((event) {
      if (event == null){
        print("Error with video height");
        height = -1;
      }else {
        height = event.toDouble();
      }
      setState(() {

      });
    });

    await _player.open(Media(widget.url), play: false);
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }


  @override
  void initState() {
    _player = Player();
    _controller = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: false,
      )
    );

    _initController();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    double vWidth = min(width, widget.maxWidth);
    return
      width == -1 || height == -1 ? Container(
        width: widget.maxWidth,
        height: widget.maxWidth / 2,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: (widget.maxWidth / 2 - 40) / 2 , horizontal: (widget.maxWidth - 40) / 2 ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
      ) :
      Video(
        key: _key,
        fit: BoxFit.fill,
        width: vWidth,
        height: height * vWidth / width,
        controller: _controller,
      );
  }
}
