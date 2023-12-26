import 'package:flutter/material.dart';
import 'package:gigachat/widgets/video-player.dart';

class LocalVideoPlayer extends StatelessWidget {
  final String path;
  const LocalVideoPlayer({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return VideoPlayerWidget(
        videoUrl: path,
        autoPlay: false,
        showControllers: true,
        tag: ""
    );
  }
}

