import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  late VideoPlayerController _controller;
  late FlickManager _manager;
  late bool loading;

  @override
  void initState() {
    super.initState();
    loading = true;
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.seekTo(Duration.zero);

        widget.autoPlay ? _controller.play() : _controller.pause();

        loading = false;
        try
        {
          setState(() {});
        }catch(e){
          print("Handled Exception $e");
        }
      });
    _manager = FlickManager(videoPlayerController: _controller);

  }

  @override
  void dispose() {
    super.dispose();
    _manager.dispose();
    //_controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        onVisibilityChanged: (info){
          info.visibleFraction * 100 > 80 ? _controller.play() : _controller.pause();
        },
        key: Key(widget.tag),
        child: FlickVideoPlayer(
          flickManager: _manager,
          flickVideoWithControls: widget.showControllers ? const FlickVideoWithControls(
            videoFit: BoxFit.fitWidth,
            controls: FlickPortraitControls(),
          ) : const SizedBox.shrink(),
        ),
    );
  }
}
