import 'package:flutter/material.dart';
import 'package:gigachat/providers/auth.dart';

class ChatSettingsPage extends StatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {

  int _directMessages = 0;
  bool _sendReadReceipts = true;

  @override
  Widget build(BuildContext context) {
    Auth auth = Auth.getInstance(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Messages settings",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              "@${auth.getCurrentUser()!.id}",
              style: const TextStyle(
                color: Colors.blueGrey,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Allow message requests from:",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                  ),
                ),
                const Text(
                  "People you follow will always be able to messgage you.",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                  ),
                ),

                RadioListTile<int>(
                  value: 0,
                  groupValue: _directMessages,
                  onChanged: (v) {
                    setState(() {
                      _directMessages = v!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: const Text(
                    "No one",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                RadioListTile<int>(
                  value: 1,
                  groupValue: _directMessages,
                  onChanged: (v) {
                    setState(() {
                      _directMessages = v!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: const Text(
                    "Verified users",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                RadioListTile<int>(
                  value: 2,
                  groupValue: _directMessages,
                  onChanged: (v) {
                    setState(() {
                      _directMessages = v!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: const Text(
                    "Everyone",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: Colors.blueGrey,
            height: 4,
            thickness: 0.1,
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SwitchListTile(
              value: _sendReadReceipts,
              onChanged: (v) {
                setState(() {
                  _sendReadReceipts = v;
                });
              },
              title: Text("Send read receipts" , style: TextStyle(fontWeight: FontWeight.w500),),
              subtitle: Text("Let people you're messaging with know when you've seen their messages. Read receipts are not shown on message requests."),
            ),
          ),
        ],
      ),
    );
  }
}
