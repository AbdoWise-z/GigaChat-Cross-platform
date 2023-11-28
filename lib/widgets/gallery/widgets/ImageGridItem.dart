import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGridItem extends StatefulWidget {
  final bool enabled;
  final AssetEntity entity;
  final ThumbnailOption option;
  final Function() onTap;
  final bool selected;
  const ImageGridItem({
    Key? key,
    required this.enabled,
    required this.entity,
    required this.option,
    required this.onTap,
    required this.selected
  }) : assert(enabled || !selected), super(key: key);

  @override
  State<ImageGridItem> createState() => _ImageGridItemState();
}

class _ImageGridItemState extends State<ImageGridItem> with SingleTickerProviderStateMixin{
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

  @override
  void initState() {
    super.initState();
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
                  child: AssetEntityImage(
                    widget.entity,
                    isOriginal: false,
                    thumbnailSize: widget.option.size,
                    thumbnailFormat: widget.option.format,
                    fit: BoxFit.cover,
                  ),
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