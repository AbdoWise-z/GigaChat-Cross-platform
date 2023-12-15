import 'package:flutter/material.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/Follow-Button.dart';

class SearchKeyword extends StatelessWidget {
  final String tag;
  final void Function() onPressed;
  final void Function() onIconClick;
  const SearchKeyword({
    super.key,
    required this.tag,
    required this.onIconClick,
    required this.onPressed
  });
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeProvider.getInstance(context).isDark();
    return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            padding: const EdgeInsets.all(15),
            alignment: Alignment.centerLeft
          ),
          child: Row(
            children: [
              Text("#$tag", style: const TextStyle(fontSize: 17)),
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: onIconClick,
                child: const Icon(Icons.arrow_outward),
              )
            ],
          ),
        );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  const UserResult({super.key,required this.user});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeProvider.getInstance(context).isDark();
    return TextButton(
      onPressed: (){
        print("Profile page prints ${user.name}");
        Navigator.push(context,
          MaterialPageRoute(
              builder: (context) => UserProfile(username: user.id, isCurrUser: false)
          ),
        );
      },
      style: TextButton.styleFrom(
          foregroundColor: isDarkMode ? Colors.white: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(backgroundImage: NetworkImage(user.iconLink)),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name),
                  Text("@${user.id}",style: TextStyle(color: Colors.grey),)
                ],
              ),
              Expanded(child: SizedBox()),
              SizedBox(
                width: 80,
                height: 30,
                child: Visibility(
                  visible: Auth.getInstance(context).getCurrentUser()!.id != user.id,
                  child: FollowButton(
                      isFollowed: user.isFollowed!,
                      callBack: (isFollowed){user.isFollowed = isFollowed;},
                      username: user.id
                  ),
                ),
              )
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundColor: Colors.transparent),
              SizedBox(width: 10,),
              Text("ajdoklasjdklasdlkasmdlk",style: TextStyle(color: Colors.white),)
            ],
          )
        ],
      )
    );
  }
}