import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';
import '../base.dart';

PreferredSizeWidget LoginAppBar(BuildContext context) {
  return AppBar(
    centerTitle: true,
    leading: IconButton(
      onPressed: (){
        Navigator.popUntil(context,ModalRoute.withName('/'));
      },
      icon: const Icon(Icons.close),
    ),
    title: SizedBox(
      height: 40,
      width: 40,
      child: Image.asset(
        ThemeProvider.getInstance(context).isDark() ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png',
      ),
    ),
  );
}
