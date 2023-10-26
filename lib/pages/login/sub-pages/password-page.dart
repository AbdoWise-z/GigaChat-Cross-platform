import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/login/controllers/password-controller.dart';
import 'package:gigachat/pages/login/shared-widgets/forget-password-button.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/page-title.dart';
import 'package:gigachat/widgets/password-input-field.dart';

import '../../../widgets/username-input-field.dart';



class PasswordLoginPage extends StatefulWidget {
  String? username;

  PasswordLoginPage({this.username,super.key});


  @override
  State<PasswordLoginPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<PasswordLoginPage> {
  String? username = "";
  String? password;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.username;
    password = "";
  }

  @override
  Widget build(BuildContext context) {


    return Theme(
        data: ThemeData(
            brightness: Brightness.dark,
          disabledColor: const Color(0xffFAFAFA)
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: LoginAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // page Title
                const PageTitle(title: PASSWORD_PAGE_DESCRIPTION),

                // empty space
                const SizedBox(height: 30),

                // username input field - disabled -
                TextDataFormField(onChange: (email){}, value: username, isEnabled: false),

                // empty space
                const SizedBox(height: 20),

                // password field
                PasswordFormField(
                    onChanged: (value) {password = value;},
                    validator: (value){return value.length > 5;},
                    label: "Password",
                ),
                const Expanded(child: SizedBox()),

                LoginFooter(proceedButtonName: "Log in",username: username)
              ],
            ),
          ),
        )
    );
  }
}
