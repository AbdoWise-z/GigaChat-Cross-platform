import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String tag;
  final String videoUrl;
  final bool autoPlay;
  final bool holdVideo;
  final bool showControllers;
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.autoPlay,
    required this.holdVideo,
    required this.showControllers,
    required this.tag
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late bool loading;

  @override
  void initState() {
    super.initState();
    loading = true;
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.seekTo(Duration.zero);

        widget.autoPlay && !widget.holdVideo ? _controller.play() : _controller.pause();
        loading = false;
        try
        {
          setState(() {});
        }catch(e){
          print("Handled Exception $e");
        }
      });

  }

  @override
  Widget build(BuildContext context) {

    if (loading){
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.holdVideo){
      return Stack(
        children: [
         VideoPlayer(_controller),

          loading ? const SizedBox() :
          const Center(child: Icon(Icons.play_circle,color: Colors.blue,size: 50,))
        ],
      );
    }

    if (widget.showControllers){
      return FlickVideoPlayer(flickManager: FlickManager(videoPlayerController: _controller));
    }

    return VisibilityDetector(
        onVisibilityChanged: (info){
          info.visibleFraction * 100 > 80 ? _controller.play() : _controller.pause();
        },
        key: Key(widget.tag),
        child: VideoPlayer(_controller)
    );
  }
}
