import 'package:flutter/material.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/tweets-requests.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/posts/view-post.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';

class ProfileNotificationNavigation extends StatefulWidget {
  final String target;
  final bool chat;
  const ProfileNotificationNavigation({super.key, required this.target , this.chat = false});

  @override
  State<ProfileNotificationNavigation> createState() => _ProfileNotificationNavigationState();
}

class _ProfileNotificationNavigationState extends State<ProfileNotificationNavigation> {
  void _load() async {
    if (Globals.isLoadingChat){
      Navigator.pop(context);
    }
    if (widget.chat){
      Globals.isLoadingChat = true;
    }
    var res = await Account.apiUserProfileWithID(Auth().getCurrentUser()!.auth!, widget.target);
    if (res.data != null){
      if (context.mounted){
        if (!widget.chat) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) =>
                UserProfile(username: res.data!.id, isCurrUser: false),
          ));
        } else {
          Navigator.pop(context); //pop this page
          if (Globals.currentActiveChat != widget.target){
            if (Globals.currentActiveChat != null){
              Navigator.pop(context); //pop the chat page
            }
            Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
              "user" : res.data!,
            });
          }
        }
        print("Notification delivered");
      }
    }else{
      print("Failed to trigger notification with ID : ${widget.target}");
    }
    if (widget.chat){
      Globals.isLoadingChat = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }
  @override
  Widget build(BuildContext context) {
    return const LoadingPage();
  }
}
