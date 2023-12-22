import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SingleFrameVideoPlayer extends StatefulWidget {
  final String tag;
  final String videoUrl;
  const SingleFrameVideoPlayer({super.key, required this.tag, required this.videoUrl});

  @override
  State<SingleFrameVideoPlayer> createState() => _SingleFrameVideoPlayerState();
}

class _SingleFrameVideoPlayerState extends State<SingleFrameVideoPlayer> {
  late VideoPlayerController _controller;
  late bool loading;
  @override
  void initState() {
    loading = true;
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _controller.seekTo(Duration.zero);
        _controller.pause();
        try
        {
          setState(() {
            loading = false;
          });
        }catch(e){
          print("Handled Exception $e");
        }
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(_controller),
        loading ? const SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(),
        ) :
        const Center(
          child: Icon(
          Icons.play_circle,
          color: Colors.blue,size: 50,),
        )
      ],
    );
  }
}
