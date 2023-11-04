import 'package:flutter/material.dart';
import '../../base.dart';


class PageDescription extends StatelessWidget {
  final String description;
  const PageDescription({super.key,required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(description,
      style: const TextStyle(
        fontSize: 17
    ),);
  }
}
