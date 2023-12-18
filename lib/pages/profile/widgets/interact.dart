import 'package:flutter/material.dart';
import 'package:gigachat/pages/profile/widgets/follow-button.dart';

import '../../../providers/theme-provider.dart';
import 'avatar.dart';

class ProfileInteract extends StatelessWidget {
  const ProfileInteract({Key? key,required this.isCurrUser, this.onTapDM,
    required this.onTapEditProfile,required this.onTapFollow,
    this.isWantedUserFollowed, required this.onTapUnfollow,
    this.isWantedUserBlocked, required this.isHeader,
    required this.avatarImageUrl, required this.avatarIsVisible,
    this.onTapUnblock}) : super(key: key);

  final bool isCurrUser;
  final bool? isWantedUserFollowed;
  final bool? isWantedUserBlocked;
  final bool isHeader;
  final bool avatarIsVisible;
  final String avatarImageUrl;
  final void Function()? onTapEditProfile;
  final void Function() onTapFollow;
  final void Function()? onTapDM;
  final void Function() onTapUnfollow;
  final void Function()? onTapUnblock;




  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: avatarIsVisible ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Visibility(
          visible: avatarIsVisible,
          child: ProfileAvatar(
            avatarImageUrl: avatarImageUrl,
            avatarPadding: const EdgeInsets.fromLTRB(13, 0, 0, 5),
            avatarRadius: 20,
            onTap: (){},  //TODO:
          ),
        ),
        Visibility(
          visible: avatarIsVisible,
            child: const Expanded(child: SizedBox.shrink(),)),
        Visibility(
          visible: !isCurrUser && !isHeader && (isWantedUserBlocked != null && !isWantedUserBlocked!),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1,
                    color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black)
            ),
            child: IconButton(
              splashRadius: 17.5,
              icon: Icon(Icons.mail_outline,
                size: 17.5,
                color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black,
              ),
              onPressed: onTapDM,
            ),
          ),
        ),
        const SizedBox(width: 10,),
        isCurrUser? OutlinedButton(
          onPressed: onTapEditProfile,
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              )
          ),
          child: const Text("Edit profile",style: TextStyle(fontWeight: FontWeight.bold),),
        ) : (isWantedUserBlocked != null && isWantedUserBlocked!) ?
        OutlinedButton(
          onPressed: onTapUnblock,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
              )
          ),
          child: const Text("Blocked",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
        ) :
        (isWantedUserFollowed != null && !isWantedUserFollowed!) ?
        FollowButton(
          onPressed: onTapFollow,
          padding: const EdgeInsets.symmetric(horizontal: 30),
        ) :
        OutlinedButton(
          onPressed: onTapUnfollow,
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.blueGrey),
              )
          ),
          child: const Text("Following",style: TextStyle(fontWeight: FontWeight.bold),),
        )
      ],
    );
  }
}
