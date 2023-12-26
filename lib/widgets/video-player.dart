import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
  as media_kit_video_controls;

class VideoPlayerWidget extends StatefulWidget {
  final String tag;
  final String videoUrl;
  final bool autoPlay;
  final bool showControllers;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.autoPlay,
    required this.showControllers,
    required this.tag
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoController _controller;
  late Player _player = Player();

  @override
  void initState() {
    super.initState();
    _controller = VideoController(_player);
    _player.open(Media(widget.videoUrl) , play: widget.autoPlay);
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      fit: BoxFit.fitWidth,
      controller: _controller,
      controls: widget.showControllers ? media_kit_video_controls.AdaptiveVideoControls : (w) => const SizedBox.shrink(),
    );
  }
}
