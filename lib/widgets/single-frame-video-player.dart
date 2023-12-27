import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// this widget loads the first frame of the video and show it to the user
/// hiding its controllers so that user cannot play the videos unless it was pressed
/// and fullscreen media is opened
/// [tag] : a unique identifier for the video
/// [videoUrl] : url for the video to be displayed
class SingleFrameVideoPlayer extends StatefulWidget {
  final String tag;
  final String videoUrl;
  const SingleFrameVideoPlayer({super.key, required this.tag, required this.videoUrl});

  @override
  State<SingleFrameVideoPlayer> createState() => _SingleFrameVideoPlayerState();
}

class _SingleFrameVideoPlayerState extends State<SingleFrameVideoPlayer> {
  late VideoController _controller;
  late Player _player;

  void _init() async {
    await _controller.waitUntilFirstFrameRendered;
    _player.pause();
  }

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.open(Media(widget.videoUrl) , play: true);
    _player.setVolume(0);
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Video(
          controller: _controller,
          controls: (w) => SizedBox(),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.blue,
                size: 38,
              ),
            ),
          ),
        )
      ],
    );
  }
}
