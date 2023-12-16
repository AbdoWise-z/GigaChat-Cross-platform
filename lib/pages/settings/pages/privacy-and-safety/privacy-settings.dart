import 'package:flutter/material.dart';
import 'package:gigachat/pages/settings/pages/privacy-and-safety/mute-and-block/mute-and-block.dart';
import 'package:gigachat/pages/settings/widgets/app-bar-title.dart';

import '../../../../widgets/text-widgets/main-text.dart';
import '../../widgets/settings-tile.dart';

class PrivacySettings extends StatelessWidget {
  const PrivacySettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettingsAppBarTitle(text: "Privacy and safety"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(height: 1,color: Colors.blueGrey,),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ListTile(
              minVerticalPadding: 20,
              subtitle: MainText(
                text: "Your Gigachat activity",
                color: Colors.blueGrey,
              ),
            ),
            SettingsTile(
              icon: Icons.block,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MuteAndBlockSettings()
                  )
                );
              },
              mainText: "Mute and block",
              description: "Manage the accounts, words, and notifications that you,ve"
                  "muted or blocked",
            ),
            SettingsTile(
              icon: Icons.mail_outline,
              onTap: (){
                //TODO: go to abdo message settings
              },
              mainText: "Direct messages",
              description: "Manage who can message you directly",
            ),
          ],
        ),
      ),
    );
  }
}
