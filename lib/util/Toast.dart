
import 'package:flutter/material.dart';

/// Used to show a toast (the small message in the bottom of screen in android) with a message
class Toast{
  static void showToast(BuildContext context,String message,{double width = 16}) {
    if(!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.symmetric(horizontal: width),
        content: Container(
          alignment: Alignment.center,
          child: Text(message),
        ),
        behavior: SnackBarBehavior.floating,
      )
    );
  }
}