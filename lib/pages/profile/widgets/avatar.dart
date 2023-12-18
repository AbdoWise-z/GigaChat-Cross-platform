import 'package:flutter/material.dart';

import '../../../providers/theme-provider.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({Key? key,required this.avatarImageUrl,
    required this.avatarPadding,required this.avatarRadius,required this.onTap}) : super(key: key);

  final double avatarRadius;
  final EdgeInsetsGeometry avatarPadding;
  final String avatarImageUrl;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: avatarPadding,
      width: 2 * avatarRadius,
      height: 2 * avatarRadius,
      transformAlignment: AlignmentDirectional.bottomCenter,
      duration: const Duration(milliseconds: 10),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: ThemeProvider.getInstance(context).isDark()? Colors.black : Colors.white,
              width: 3)
      ),
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: avatarRadius,
          backgroundImage: avatarImageUrl == ""? null : NetworkImage(avatarImageUrl,),
        ),
      ),
    );
  }
}
