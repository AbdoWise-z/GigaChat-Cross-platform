import 'package:flutter/material.dart';
import 'package:gigachat/widgets/gallery/gallery.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photo_manager/photo_manager.dart';

/// represents a Gallery grid item
/// [enabled] weather this cell is clickable
/// [entity] the media inside this cell
/// [onTap] on click event handler
/// [selected] is this cell selected
class GalleryGridItem extends StatefulWidget {
  final bool enabled;
  final MediaEntity entity;
  final Function() onTap;
  final bool selected;
  const GalleryGridItem({
    Key? key,
    required this.enabled,
    required this.entity,
    required this.onTap,
    required this.selected
  }) : assert(enabled || !selected), super(key: key);

  @override
  State<GalleryGridItem> createState() => _GalleryGridItemState();
}

class _GalleryGridItemState extends State<GalleryGridItem> with SingleTickerProviderStateMixin{
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  Player? player;
  VideoController? videoPlayerController;


  Future<void> _initVideoPlayer() async {
    if (widget.entity.entity.type != AssetType.video) return;
    player = Player();
    videoPlayerController = VideoController(player!);
    await player!.open(Media(widget.entity.path.path));
    await player!.setVolume(0);

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    if (player != null){
      player!.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.enabled){
          widget.onTap();
        }
      },
      onPanDown: (d) {
        _controller.forward(from: _controller.value);
      },
      onPanCancel: () {
        _controller.reverse(from: _controller.value);
      },
      onPanEnd: (d) {
        _controller.reverse(from: _controller.value);
      },

      child: Padding(
        padding: const EdgeInsets.all(0.5),
        child: Transform.scale(
          scale: 1 - 0.1 * _controller.value,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: widget.entity.entity.type == AssetType.image ? Image.file(
                    widget.entity.path,
                    fit: BoxFit.cover,
                  ) : videoPlayerController == null ? const Padding(
                    padding: EdgeInsets.all(34.0),
                    child: CircularProgressIndicator(),
                  ) : Video(controller: videoPlayerController!,controls: null,),
                ),
              ),
              Visibility(
                visible: widget.selected,
                child: Positioned.fill(
                  child:
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                      color: Colors.black45,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle ,
                        color: Colors.green,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: !widget.enabled,
                child: Positioned.fill(
                  child:
                  Container(
                    color: Colors.white30,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}