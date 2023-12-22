import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/settings/widgets/app-bar-title.dart';
import 'package:gigachat/providers/auth.dart';

import '../../../../../widgets/text-widgets/main-text.dart';

class MuteAndBlockSettings extends StatelessWidget {
  const MuteAndBlockSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettingsAppBarTitle(text: "Mute and block"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(height: 1, color: Colors.blueGrey,),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ListTile(
              minVerticalPadding: 20,
              subtitle: MainText(
                text: "Manage the accounts, words, and notifications that you,ve"
                    "muted or blocked",
                color: Colors.blueGrey,
              ),
            ),
            ListTile(
              minVerticalPadding: 20,
              splashColor: Colors.transparent,
              title: const MainText(text: "Blocked accounts",),
              onTap: (){
                Navigator.pushNamed(context, UserListViewPage.pageRoute,arguments: {
                  "pageTitle": "Blocked accounts",
                  "tweetID" : null,
                  "userID" : Auth.getInstance(context).getCurrentUser()!.id,
                  "providerFunction" : ProviderFunction.GET_USER_BLOCKLIST
                });
              },
            ),
            ListTile(
              splashColor: Colors.transparent,
              minVerticalPadding: 20,
              title: const MainText(text: "Muted accounts",),
              onTap: (){
                Navigator.pushNamed(context, UserListViewPage.pageRoute,arguments: {
                  "pageTitle": "Muted accounts",
                  "tweetID" : null,
                  "userID" : Auth.getInstance(context).getCurrentUser()!.id,
                  "providerFunction" : ProviderFunction.GET_USER_MUTEDLIST
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
