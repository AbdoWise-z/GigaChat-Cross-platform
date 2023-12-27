import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigachat/widgets/gallery/gallery.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photo_manager/photo_manager.dart';

/// A wrapper around the post media since it can vary depending on the media type
/// this Widget is responsible of displaying the write type of media (video / image)
/// takes two inputs [media] the the media to display
/// and [width] the maximum width allowed for this media
///
class PostMediaView extends StatefulWidget {
  final TypedEntity media;
  final double width;
  const PostMediaView({super.key, required this.media, required this.width});

  @override
  State<PostMediaView> createState() => _PostMediaViewState();
}

class _PostMediaViewState extends State<PostMediaView> {
  late final VideoController _controller;
  late Player? _player;
  final GlobalKey _key = GlobalKey();

  double width = -1;
  double height = -1;

  void _initController() async {
    if (widget.media.type == AssetType.image) return;

    _player!.stream.width.listen((event) {
      if (event == null){
        print("Error with video width");
        width = -1;
      }else {
        width = event.toDouble();
      }
      setState(() {

      });
    });

    _player!.stream.height.listen((event) {
      if (event == null){
        print("Error with video height");
        height = -1;
      }else {
        height = event.toDouble();
      }
      setState(() {

      });
    });

    await _player!.open(Media(widget.media.path.path), play: false);
  }

  @override
  void dispose() {
    super.dispose();
    if (_player != null) {
      _player!.dispose();
    }
  }


  @override
  void initState() {
    _player = Player();
    _controller = VideoController(_player!);

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
    ) :
    width == -1 || height == -1 ? SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(),
    ) :
    Video(
      key: _key,
      fit: BoxFit.fill,
      width: widget.width,
      height: height * widget.width / width,
      controller: _controller,
    );
  }
}
