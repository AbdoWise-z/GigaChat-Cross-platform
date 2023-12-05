import 'dart:developer';

import 'package:flutter/material.dart';

/// SwipeTo is a wrapper widget to other Widget that we can swipe horizontally
/// to initiate a callback when animation gets end.
/// It is useful to develop and What's App kind of replay animation for a
/// component of ongoing chat.
class SwipeTo extends StatefulWidget {
  /// Child widget for which you want to have horizontal swipe action
  /// @required parameter
  final Widget child;

  ///Duration of the back animation for every 100 pixels
  ///in ms
  final double animationDuration;

  /// Icon that will be displayed beneath child widget when swipe right
  final IconData iconOnRightSwipe;

  /// Widget that will be displayed beneath child widget when swipe right
  final Widget? rightSwipeWidget;

  /// Icon that will be displayed beneath child widget when swipe left
  final IconData iconOnLeftSwipe;

  /// Widget that will be displayed beneath child widget when swipe right
  final Widget? leftSwipeWidget;

  final double triggerDx;

  final double iconSize;

  /// color value defining color of displayed icon beneath child widget
  ///if not specified primaryColor from theme will be taken
  final Color? iconColor;
  final Alignment alignment;

  final void Function()? onRightSwipe;
  final void Function()? onLeftSwipe;

  const SwipeTo({
    Key? key,
    required this.child,
    this.onRightSwipe,
    this.onLeftSwipe,
    this.iconOnRightSwipe = Icons.reply,
    this.rightSwipeWidget,
    this.iconOnLeftSwipe = Icons.reply,
    this.leftSwipeWidget,
    this.iconSize = 26.0,
    this.iconColor,
    this.animationDuration = 150,
    this.triggerDx = 15,
    this.alignment = Alignment.center,
  })  : super(key: key);

  @override
  State<SwipeTo> createState() => _SwipeToState();
}

class _SwipeToState extends State<SwipeTo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late final CurvedAnimation _curvedAnimation;
  Animation? anim;
  double _mdx = 0;
  double _dx = 0;

  @override
  initState() {
    super.initState();
    _curvedAnimation = CurvedAnimation(
      parent: _controller.drive(Tween(begin: 0.0,end: 1.0)),
      curve: Curves.decelerate,
    );

    _curvedAnimation.addListener(() {
      setState(() {
        _dx = _mdx * (1 - _curvedAnimation.value);
      });
    });

  }

  int abs(int k){
    return k < 0 ? -k : k;
  }

  double absD(double k){
    return k < 0 ? -k : k;
  }

  @override
  dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var leftO = widget.iconSize - _dx;
    leftO = leftO / widget.iconSize;
    leftO = 1 - leftO;
    if (leftO > 1) leftO = 1;
    else if (leftO < 0) leftO = 0;

    var rightO = widget.iconSize + _dx;
    rightO = rightO / widget.iconSize;
    rightO = 1 - rightO;
    if (rightO > 1) rightO = 1;
    else if (rightO < 0) rightO = 0;

    if (widget.onRightSwipe == null) leftO = 0;
    if (widget.onLeftSwipe == null) rightO = 0;

    double _idx = _dx;
    if (_idx < 0 && widget.onLeftSwipe == null)  _idx = _idx / 10;
    if (_idx > 0 && widget.onRightSwipe == null) _idx = _idx / 10;


    return GestureDetector(
      onPanUpdate: (details) {
        _dx += details.delta.dx;
        setState(() {});
      },

      onPanStart: (_) {
        _controller.stop();
      },

      onPanEnd: (_){
        _mdx = _dx;
        _controller.duration = Duration(milliseconds: abs(widget.animationDuration * _dx ~/ 100));
        _controller.forward(from: 0);
        if (absD(_dx) >= widget.triggerDx){
          if (widget.onLeftSwipe != null && _dx < 0) widget.onLeftSwipe!();
          if (widget.onRightSwipe != null && _dx > 0) widget.onRightSwipe!();

        }
      },

      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.loose,
        clipBehavior: Clip.antiAlias,

        children: [
          Positioned(
            right: 0,
            child: Opacity(
              opacity: rightO,
              child: Transform.translate(
                offset: Offset(widget.iconSize + _dx < 0 ? 0 : widget.iconSize + _dx, 0),
                child: widget.rightSwipeWidget ??
                    Icon(
                      widget.iconOnRightSwipe,
                      size: widget.iconSize,
                      color:
                      widget.iconColor ?? Theme.of(context).iconTheme.color,
                    ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            child: Opacity(
              opacity: leftO,
              child: Transform.translate(
                offset: Offset(-widget.iconSize + _dx > 0 ? 0 : -widget.iconSize + _dx, 0),
                child: widget.leftSwipeWidget ??
                    Icon(
                      widget.iconOnLeftSwipe,
                      size: widget.iconSize,
                      color:
                      widget.iconColor ?? Theme.of(context).iconTheme.color,
                    ),
              ),
            ),
          ),
          Align(
            alignment: widget.alignment,
            child: Transform.translate(
              offset: Offset(_idx, 0),
              child: widget.child,
            ),
          ),

        ],
      ),
    );
  }
}
