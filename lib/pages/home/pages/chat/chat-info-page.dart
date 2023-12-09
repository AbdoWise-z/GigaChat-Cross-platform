import 'package:flutter/material.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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

                SizedBox(height: 20,),

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

                Divider(thickness: 1,),


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
                  thickness: 0.1,
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
                        title: const Text(
                          "Block User",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {

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
    );
  }
}
