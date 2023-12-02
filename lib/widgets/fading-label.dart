import 'package:flutter/material.dart';

//TODO: complete this maybe ..

class FadingLabel extends StatefulWidget {
  final bool fade;
  final Widget label;
  const FadingLabel({super.key, required this.fade, required this.label});

  @override
  State<FadingLabel> createState() => _FadingLabelState();
}

class _FadingLabelState extends State<FadingLabel> with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(vsync: this , duration: const Duration(milliseconds: 300));
  late final AnimationController _size = AnimationController(vsync: this , duration: const Duration(milliseconds: 300));

  late Animation alpha;
  late Animation scale;

  @override
  void initState() {
    super.initState();
    alpha = Tween(begin: 0 , end: 1).animate(_fade);
    scale = Tween(begin: 0 , end: 1).animate(_size);

  }

  @override
  Widget build(BuildContext context) {

    return const Placeholder();
  }
}
