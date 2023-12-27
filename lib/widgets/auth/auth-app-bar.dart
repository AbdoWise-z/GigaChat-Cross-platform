import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';

/// App bar for authentication pages
PreferredSizeWidget AuthAppBar(BuildContext context,{
  required IconButton? leadingIcon,
  bool? showDefault
})
{
  return AppBar(
    centerTitle: true,
    leading: leadingIcon,
    automaticallyImplyLeading: showDefault ?? false,
    title: SizedBox(
      height: 40,
      width: 40,
      child: Image.asset(
        ThemeProvider.getInstance(context).isDark() ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png',
      ),
    ),
  );
}
