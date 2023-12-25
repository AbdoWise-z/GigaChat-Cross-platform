import 'package:flutter/material.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/util/Toast.dart';
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
              Text("$tag", style: const TextStyle(fontSize: 17)),
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

class UserResult extends StatefulWidget {
  final User user;
  final bool disableFollowButton;
  const UserResult({super.key,required this.user, required this.disableFollowButton});

  @override
  State<UserResult> createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeProvider.getInstance(context).isDark();
    return TextButton(
      onPressed: (){
        print("Profile page prints ${widget.user.name}");
        if(widget.user.id != Auth.getInstance(context).getCurrentUser()!.id){
          Navigator.push(context,
            MaterialPageRoute(
                builder: (context) => UserProfile(username: widget.user.id, isCurrUser: false)
            ),
          );
        }
      },
      style: TextButton.styleFrom(
          foregroundColor: isDarkMode ? Colors.white: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(backgroundImage: NetworkImage(widget.user.iconLink)),
              const SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user.name, overflow: TextOverflow.ellipsis,),
                    Text("@${widget.user.id}",style: const TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis,)
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              Visibility(
                visible: (widget.user.isWantedUserMuted != null && widget.user.isWantedUserMuted!),
                child: IconButton(
                    onPressed: () async {
                      await Auth.getInstance(context).unmute(
                        widget.user.id,
                        success: (res){
                          setState(() {
                            widget.user.isWantedUserMuted = false;
                          });
                        },
                        error: (res){
                          Toast.showToast(context, "Action failed, please try again");
                        }
                      );
                    }, icon: const Icon(Icons.volume_off_sharp,color: Colors.red,)
                ),
              ),
              Visibility(
                visible: Auth.getInstance(context).getCurrentUser()!.id != widget.user.id && !widget.disableFollowButton,
                child: SizedBox(
                  width: 90,
                  height: 30,
                  child: (widget.user.isWantedUserBlocked != null && widget.user.isWantedUserBlocked!)?
                  ElevatedButton(
                    onPressed: () async{
                      await Auth.getInstance(context).unblock(
                          widget.user.id,
                        success: (res){
                           setState(() {
                             widget.user.isWantedUserBlocked = false;
                           });
                        },
                        error: (res){
                          Toast.showToast(context, "Action failed, please try again");
                        }
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15.0), // Set the border radius
                      ),
                    ),
                    child: const Text("Blocked"),
                  ):
                  FollowButton(
                      isFollowed: widget.user.isFollowed!,
                      callBack: (isFollowed){widget.user.isFollowed = isFollowed;},
                      username: widget.user.id
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 50,),
              Expanded(
                child: Text(
                  widget.user.bio,style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          )
        ],
      )
    );
  }
}