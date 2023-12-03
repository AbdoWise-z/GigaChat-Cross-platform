import 'package:flutter/material.dart';

class ProfileBanner extends StatelessWidget {
  const ProfileBanner({Key? key,required this.bannerImageUrl,required this.onTap}) : super(key: key);

  final String bannerImageUrl;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        color: Colors.blue,
        child: Image.network(bannerImageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
