import 'package:flutter/material.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-information/account-information.dart';
import 'package:gigachat/pages/settings/pages/your-account/change-your-password/change-your-password.dart';
import 'package:gigachat/pages/settings/settings-titles.dart';
import 'package:gigachat/pages/settings/widgets/app-bar-title.dart';
import 'package:gigachat/pages/settings/widgets/settings-tile.dart';
import 'package:gigachat/widgets/text-widgets/main-text.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({Key? key}) : super(key: key);

  static const pageRoute = '/account-settings';
  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SettingsAppBarTitle(text: settingsTitles[titles.YOUR_ACCOUNT.index].title),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(height: 1,color: Colors.blueGrey,)
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              minVerticalPadding: 20,
                subtitle: MainText(
                  text: settingsTitles[titles.YOUR_ACCOUNT.index].description,
                  color: Colors.blueGrey,
                ),
            ),
            SettingsTile(
              icon: Icons.person_outline,
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountInformation()));
                setState(() {});
              },
              mainText: "Account information",
              description: "See your account information like your"
                  " phone number and email address",
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>
                        const ChangePasswordPage(),
                  )
                );
              },
              mainText: "Change your password",
              description: "Change your password at any time",
            ),
          ],
        ),
      ),
    );
  }
}
