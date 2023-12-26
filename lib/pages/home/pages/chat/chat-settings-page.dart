import 'package:flutter/material.dart';
import 'package:gigachat/pages/settings/widgets/app-bar-title.dart';

import '../../../../widgets/text-widgets/main-text.dart';

class ChatSettingsPage extends StatefulWidget {
  static bool isOpen = false;
  const ChatSettingsPage({super.key});

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {

  int _directMessages = 0;
  bool _sendReadReceipts = true;

  @override
  void initState() {
    ChatSettingsPage.isOpen = true;
    super.initState();
  }

  @override
  void dispose() {
    ChatSettingsPage.isOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettingsAppBarTitle(text: "Messages Settings"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(height: 1,color: Colors.blueGrey,),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              minVerticalPadding: 20,
              title: MainText(
                text: "Allow message requests from:",
                size: 20,
                bold: true,
              ),
              subtitle: MainText(
                text: "People you follow will always be able to message you.",
                color: Colors.blueGrey,
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
            const Divider(
              color: Colors.blueGrey,
              height: 1,
            ),
            const SizedBox(height: 15,),
            SwitchListTile(
              value: _sendReadReceipts,
              onChanged: (v) {
                setState(() {
                  _sendReadReceipts = v;
                });
              },
              title: Text("Send read receipts" , style: TextStyle(fontWeight: FontWeight.w500),),
              subtitle: MainText(text: "Let people you're messaging with know when you've seen "
                  "their messages. Read receipts are not shown on message requests.", color: Colors.blueGrey,),
            ),
          ],
        ),
      ),
    );
  }
}
