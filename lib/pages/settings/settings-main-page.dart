import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/pages/notification/subPages/notificationSetting.dart';
import 'package:gigachat/pages/settings/pages/privacy-and-safety/privacy-settings.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-settings.dart';
import 'package:gigachat/pages/settings/settings-titles.dart';
import 'package:gigachat/pages/settings/widgets/app-bar-title.dart';
import 'package:gigachat/pages/settings/widgets/settings-tile.dart';
import 'package:gigachat/widgets/text-widgets/main-text.dart';

import '../../providers/theme-provider.dart';

class MainSettings extends StatefulWidget {
  const MainSettings({Key? key}) : super(key: key);

  static const pageRoute = '/settings';

  @override
  State<MainSettings> createState() => _MainSettingsState();
}

class _MainSettingsState extends State<MainSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettingsAppBarTitle(text: "Settings"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Column(
            children: [
              const Divider(height: 0.1,color: Colors.blueGrey,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                child: GestureDetector(
                  onTap: (){},
                  child: Container(
                    constraints: const BoxConstraints.expand(height: 40),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ThemeProvider.getInstance(context).isDark() ? const Color.fromARGB(30, 200, 255, 235) : const Color.fromARGB(30, 100, 155, 135),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      border: Border.all(
                        width: 0.8,
                        color: Colors.blueGrey,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(Icons.search,color: Colors.blueGrey,),
                        ),
                        MainText(
                          text: "Search settings",
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingsTile(
              icon: Icons.person_2_outlined,
              mainText: settingsTitles[titles.YOUR_ACCOUNT.index].title,
              description: settingsTitles[titles.YOUR_ACCOUNT.index].description,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const AccountSettings()
                  )
                );
                setState(() {

                });
              },
            ),
            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              mainText: settingsTitles[titles.PRIVACY.index].title,
              description: settingsTitles[titles.PRIVACY.index].description,
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PrivacySettings()
                  )
                );
              },
            ),
            SettingsTile(
              icon: Icons.notifications_none,
              mainText: settingsTitles[titles.NOTIFICATIONS.index].title,
              description: settingsTitles[titles.NOTIFICATIONS.index].description,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage()));
              },  //TODO: navigate to notifications settings
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              mainText: settingsTitles[titles.SECURITY.index].title,
              description: settingsTitles[titles.SECURITY.index].description,
              onTap: (){},
            ),
            SettingsTile(
              icon: Icons.language,
              mainText: settingsTitles[titles.ACCESSIBILITY.index].title,
              description: settingsTitles[titles.ACCESSIBILITY.index].description,
              onTap: (){},
            ),
            SettingsTile(
              icon: Icons.monetization_on_outlined,
              mainText: settingsTitles[titles.MONETIZATION.index].title,
              description: settingsTitles[titles.MONETIZATION.index].description,
              onTap: (){},
            ),
            SettingsTile(
              icon: Icons.more_horiz,
              mainText: settingsTitles[titles.ADDITIONAL.index].title,
              description: settingsTitles[titles.ADDITIONAL.index].description,
              onTap: (){},
            )
          ],
        ),
      ),
    );
  }
}
