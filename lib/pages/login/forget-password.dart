import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/login/shared-widgets/login-app-bar.dart';
import 'package:gigachat/pages/login/shared-widgets/page-footer.dart';
import 'package:gigachat/pages/login/shared-widgets/username-input-field.dart';

class ForgetPassword extends StatefulWidget {
  static const String pageRoute = "/forget-password";

  String? username;
  ForgetPassword({super.key,this.username});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String? username;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoginAppBar(),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(FORGET_PASSWORD_TITLE, style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28
            ),),
            const SizedBox(height: 10),
            const Text(FORGET_PASSWORD_DESCRIPTION, style: TextStyle(
              color: Colors.white70,
              fontSize: 18
            ),),
            const SizedBox(height: 20),
            UsernameFormField(onChange: (email){}, value: username),
            const Expanded(child: SizedBox()),
            LoginFooter(proceedButtonName: "Next",
                onPressed: (){},
                showForgetPassword: false)

          ],
        ),
      ),
    );
  }
}
