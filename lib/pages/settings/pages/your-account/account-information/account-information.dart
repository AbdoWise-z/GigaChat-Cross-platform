import 'package:flutter/material.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-information/change-username.dart';
import 'package:gigachat/pages/settings/widgets/app-bar-title.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/widgets/text-widgets/main-text.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../providers/local-settings-provider.dart';
import '../../../../../providers/theme-provider.dart';
import '../../../../login/landing-login.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({Key? key}) : super(key: key);

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettingsAppBarTitle(text: "Account Information"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(height: 1,color: Colors.blueGrey,),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              splashColor: Colors.transparent,
              onTap: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ChangeUsernamePage()));
                setState(() {});
              },
              title: const MainText(text: "Username",size: 17,),
              subtitle: MainText(
                text: "@${Auth.getInstance(context).getCurrentUser()!.id}",
                color: Colors.blueGrey,
              ),
            ),
            ListTile(
              onTap: (){},
              splashColor: Colors.transparent,
              title: const MainText(text: "Phone",size: 17,),
              subtitle: const MainText(
                text: "Add",
                color: Colors.blueGrey,
              ),
            ),
            ListTile(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.pushNamed(context, "/verify-password");
              },
              title: const MainText(text: "Email",size: 17,),
              subtitle: MainText(
                text: Auth.getInstance(context).getCurrentUser()!.email,
                color: Colors.blueGrey,
              ),
            ),
            ListTile(
              splashColor: Colors.transparent,
              onTap: (){},
              title: const MainText(text: "Country",size: 17,),
              subtitle: const MainText(
                text: "Egypt",
                color: Colors.blueGrey,
              ),
            ),
            ListTile(
              splashColor: Colors.transparent,
              onTap: (){
                showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          content: SizedBox(
                            width: 300,
                            height: 125,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Log out",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                const SizedBox(height: 15,),
                                const MainText(text: "Logging out will remove all Gigachat data from this device"),
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
                                        await Auth.getInstance(context).logout();
                                      },
                                      child: Text("Log out",
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
                        )
                );
              },
              title: const MainText(text: "Log out",color: Colors.red,size: 17,),
            ),
          ],
        ),
      ),
    );
  }
}
