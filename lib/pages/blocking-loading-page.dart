import 'package:flutter/material.dart';
import 'loading-page.dart';

class BlockingLoadingPage extends StatelessWidget {
  const BlockingLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: const LoadingPage(),
      onWillPop: () async {
        return false;
      },
    );;
  }
}
