import 'package:flutter/material.dart';
import 'package:gigachat/pages/settings/widgets/app-bar-title.dart';
import 'package:gigachat/pages/settings/widgets/settings-tile.dart';
import '../../../../../widgets/text-widgets/main-text.dart';
import 'FilterSettingsPage.dart';
import 'PreferenceSettingsPage.dart';

class NotificationSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettingsAppBarTitle(text: "Notifications"),
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
              subtitle: MainText(
                text: "Select the kinds of notifications you get about your"
                    "activities, interests, and recommendations.",
                color: Colors.blueGrey,
              ),
            ),
            SettingsTile(
                icon: Icons.filter_list,
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FilterSettingsPage()));
                },
                mainText: "Filters",
                description: "Choose the notifications you'd like to see - and those you don't"
            ),
            SettingsTile(
                icon: Icons.install_mobile_outlined,
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferenceSettingsPage()));
                },
                mainText: "Preferences",
                description: "Select your preferences by notification type."
            )
          ],
        ),
      )
    );
  }
}