import 'package:flutter/material.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:intl/intl.dart';


/// the chat info page, just displayed the user info
/// and allows the user to do few actions like blocking
/// that user for example
class ChatInfoPage extends StatefulWidget {
  final User _with;
  const ChatInfoPage( this._with , {super.key});

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  DateTime? snoozeUntil;
  final DateFormat format0 = DateFormat("yyyy/MM/dd");
  final DateFormat format1 = DateFormat("hh:mm aa");

  String _getSnoozeDate(){
    if (snoozeUntil == null) return "";
    if (snoozeUntil!.year == 0) return "forever";

    DateTime n = DateTime.now();
    if (snoozeUntil!.day == n.day && snoozeUntil!.year == n.year && snoozeUntil!.month == n.month){
      //same day snooze
      return format1.format(snoozeUntil!);
    }
    return format0.format(snoozeUntil!);
  }

  void _unblockUser() async {
    Auth auth = Auth.getInstance(context);
    showDialog(context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 300,
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Unblock @${widget._with.id}?",style: const TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 15,),
              const Text("They will be able to follow you and view your posts"),
              Row(
                children: [
                  const Expanded(child: SizedBox.shrink()),
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Cancel",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await auth.unblock(
                          widget._with.id,
                          success: (res){
                            widget._with.isWantedUserBlocked = false;
                            setState(() {
                              if(context.mounted){
                                Navigator.pop(context);
                                Toast.showToast(context, "You unblocked @${widget._with.id}.");
                              }
                            });
                          },
                          error: (res){
                            if(context.mounted){
                              Toast.showToast(context, "Action failed. Please try again.");
                            }
                          }
                      );
                    },
                    child: Text("Unblock",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _blockUser() async {
    Auth auth = Auth.getInstance(context);
    FeedProvider feedProvider = FeedProvider.getInstance(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 300,
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Block @${widget._with.id}?",style: const TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 15,),
              Text("@${widget._with.id} will no longer be able to follow or message you,"
                  "and you will not see notifications from @${widget._with.id}"),
              Row(
                children: [
                  const Expanded(child: SizedBox.shrink()),
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Cancel",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await auth.block(
                          widget._with.id,
                          widget._with.isFollowed!,
                          widget._with.isFollowingMe!,
                          success: (res){
                            setState(() {
                              widget._with.isWantedUserBlocked = true;
                              if(context.mounted) {
                                feedProvider.updateProfileFeed(context, UserProfile.profileFeedPosts);
                                feedProvider.updateProfileFeed(context, UserProfile.profileFeedLikes);
                              }
                              if(context.mounted){
                                Navigator.pop(context);
                                Toast.showToast(context, "You blocked @${widget._with.id}.");
                              }
                            });
                          },
                          error: (res){
                            if(context.mounted){
                              Toast.showToast(context, "Action failed. Please try again.");
                            }
                          }
                      );
                    },
                    child: Text("Block",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context , {"user" : widget._with});
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Conversation Info",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              color: Colors.blueGrey,
              height: 1,
              thickness: 0.1,
            ),

            const SizedBox(height: 5,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle
                    ),
                    child: Image.network(widget._with.iconLink,fit: BoxFit.cover,),
                  ),

                  const SizedBox(height: 20,),

                  Text(
                    widget._with.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Text(
                    widget._with.id,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(width: double.infinity,height: 8,),

                ],
              ),
            ),

            Visibility(
              visible: widget._with.id != Auth.getInstance(context).getCurrentUser()!.id,
              child: Column(
                children: [
                  const Divider(
                    color: Colors.blueGrey,
                    height: 4,
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Text(
                            "Notifications",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                            ),
                          ),
                        ),

                        SwitchListTile(
                          value: snoozeUntil != null,
                          onChanged: (v) {
                            if (v){
                              AlertDialog dialog = AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text("For 1 hour"),
                                      onTap: () {
                                        //TODO
                                        snoozeUntil = DateTime.now();
                                        setState(() {
                                          snoozeUntil = snoozeUntil!.add(const Duration(hours: 1));
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: const Text("For 8 hour"),
                                      onTap: () {
                                        //TODO
                                        snoozeUntil = DateTime.now();
                                        setState(() {
                                          snoozeUntil = snoozeUntil!.add(const Duration(hours: 8));
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: const Text("For 1 Week"),
                                      onTap: () {
                                        //TODO
                                        snoozeUntil = DateTime.now();
                                        setState(() {
                                          snoozeUntil = snoozeUntil!.add(const Duration(days: 7));
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),

                                    ListTile(
                                      title: const Text("Forever"),
                                      onTap: () {
                                        //TODO
                                        snoozeUntil = DateTime(0);
                                        Navigator.of(context).pop();
                                      },
                                    ) ,
                                  ],
                                ),
                              );
                              showDialog(context: context, builder: (_) => dialog);
                            }else {
                              setState(() {
                                snoozeUntil = null;
                              });
                            }
                          },
                          title: const Text("Snooze notifications" , style: TextStyle(fontWeight: FontWeight.w500),),
                          subtitle: snoozeUntil != null ? Text("Until ${_getSnoozeDate()}") : SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    color: Colors.blueGrey,
                    height: 4,
                    thickness: 0.5,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            widget._with.isWantedUserBlocked! ? "Unblock User" :  "Block User",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          onTap: () {
                            if (widget._with.isWantedUserBlocked!){
                              _unblockUser();
                            }else{
                              _blockUser();
                            }
                          },
                        ),

                        ListTile(
                          title: const Text(
                            "Report Conversation",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          onTap: () {

                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                title: const Text(
                  "Delete Conversation",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                onTap: () {

                },
              ),
            ),
          ],

        ),
      ),
    );
  }
}
