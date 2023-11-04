import 'package:flutter/material.dart';

class TabIndicator extends BoxDecoration {
  final BoxPainter _painter;

  TabIndicator() : _painter = _TabIndicatorPainter();

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _TabIndicatorPainter extends BoxPainter {
  final Paint _paint;

  _TabIndicatorPainter()
      : _paint = Paint()
    ..color = Colors.blue
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final double _xPos = offset.dx + cfg.size!.width / 2;
    final double _YPos = cfg.size!.height - offset.dy;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(_xPos - cfg.size!.width / 2, _YPos - 4, _xPos + cfg.size!.width / 2, _YPos),
        bottomLeft: const Radius.circular(5.0),
        bottomRight: const Radius.circular(5.0),
        topLeft: const Radius.circular(5.0),
        topRight: const Radius.circular(5.0),
      ),
      _paint,
    );
  }
}