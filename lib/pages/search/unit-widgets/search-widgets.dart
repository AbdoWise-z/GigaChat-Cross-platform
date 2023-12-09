import 'package:flutter/material.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/profile/user-profile.dart';

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
    return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
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
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.iconLink),
          ),
          const SizedBox(width: 10,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16
                ),
              ),
              Text(user.id,
                style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey
                ),
              ),
            ],
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}