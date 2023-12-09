import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({Key? key,this.backgroundColor,this.onPressed,this.textColor,this.padding}) : super(key: key);

  final void Function()? onPressed;
  final Color? textColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: backgroundColor,
        padding: padding,
      ),
      child: Text(
        "Follow",
        style: TextStyle(
          color: textColor,
        ),//TODO: change later
      ),
    );
  }
}
