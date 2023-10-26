import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/login/controllers/username-controller.dart';
import 'package:gigachat/pages/login/shared-widgets/login-app-bar.dart';
import 'package:gigachat/pages/login/shared-widgets/page-footer.dart';
import 'package:gigachat/pages/login/shared-widgets/username-input-field.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';
import '../shared-widgets/forget-password-button.dart';

class UsernameLoginPage extends StatefulWidget {
  const UsernameLoginPage({super.key});

  @override
  State<UsernameLoginPage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernameLoginPage> {
  String? username;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = "";
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(brightness: Brightness.dark),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: LoginAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [

                // Page Description
                const Text(
                  LOGIN_PAGE_DESCRIPTION,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70),
                ),

                // Empty Space
                const SizedBox(height: 20),

                // Username Input Field
                UsernameFormField(onChange: (editedUsername) {
                  setState(() {
                    username = editedUsername;
                  });
                }),

                // Empty Space
                const Expanded(child: SizedBox()),

                // Page Footer
                LoginFooter(proceedButtonName: "Next",onPressed: () async {
                  bool verified = await verifyUsername(username);
                  if (verified)
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder:
                                (context)=>
                                PasswordLoginPage(username: username)
                        )
                    );
                  }
                },)
              ],
            ),
          ),
        ));
  }
}
