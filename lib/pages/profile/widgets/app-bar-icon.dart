import 'package:flutter/material.dart';

class ProfileAppBarIcon extends StatelessWidget {
  final IconData icon;
  final void Function()? onPressed;
  final String toolTip;
  const ProfileAppBarIcon({Key? key,required this.icon,required this.onPressed,required this.toolTip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 35,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          iconSize: 22,
          tooltip: toolTip,
          icon: Icon(icon),color: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
