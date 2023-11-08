
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';

class TweetActionButton extends StatefulWidget {

  final IconData icon;
  int? count;
  bool? isLikeButton;
  bool? isShareButton;

  TweetActionButton({super.key, required this.icon, this.count,this.isLikeButton,this.isShareButton}){
    isLikeButton ??= false;
    isShareButton ??= false;
  }

  @override
  State<TweetActionButton> createState() => _TweetActionButtonState();
}

MaterialStateProperty<Color> getColor(Color defaultColor,Color onPressedColor)
{
  calcColor(Set<MaterialState> states){
    if(states.contains(MaterialState.pressed)) {
      return onPressedColor;
    } else {
      return defaultColor;
    }
  }
  return MaterialStateProperty.resolveWith(calcColor);
}

class _TweetActionButtonState extends State<TweetActionButton> {

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      size: 20,
      likeCount: widget.count,


      likeBuilder: widget.isLikeButton == true ? null : (isLiked){
        return Icon(widget.icon,size: 20,color: Colors.grey);
      },

      countDecoration: (count, likeCount) {
        likeCount ??= 0;
        return widget.isShareButton == true || likeCount < 9999 ?
        null :
        Text(NumberFormat.compact().format(likeCount));
        },

      animationDuration: Duration(seconds: widget.isLikeButton == true ? 1 : 0),
      circleSize: widget.isLikeButton == true ? null : 0,
      bubblesSize: widget.isLikeButton == true ? null : 0,
      
      onTap: (isLiked){
        return Future(() => widget.isLikeButton == true && !isLiked);
      },
    );
  }
}
