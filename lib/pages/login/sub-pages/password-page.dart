import 'package:flutter/material.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/password-input-field.dart';

class PasswordLoginPage extends StatefulWidget {
  static const String pageRoute = "/login/password";
  static const passwordFieldKey = "login-password-password-field";
  static const loginButtonKey = "login-password-login-button";

  String username;

  PasswordLoginPage({required this.username, super.key});

  @override
  State<PasswordLoginPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<PasswordLoginPage> {
  String? password;
  bool isValid = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    password = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: IconButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // page Title
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle(title: "Enter your password"),

                // empty space
                const SizedBox(height: 30),

                // username input field - disabled -
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          widget.username,
                        ),
                      ),
                    ),
                  ],
                ),

                // empty space
                const SizedBox(height: 20),

                // password field
                PasswordFormField(
                  key: const Key(PasswordLoginPage.passwordFieldKey),
                  hideBorder: true,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                      isValid = value.isNotEmpty;
                    });
                  },
                  validator: (value){
                    return value == null || value.isEmpty ? "" : null;
                  },
                  label: "Password",
                ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),

          AuthFooter(
            rightButtonKey: const Key(PasswordLoginPage.loginButtonKey),

              rightButtonLabel: "Log in",
              disableRightButton: !isValid,
              onRightButtonPressed: (){
                //TODO: call the api to login
              },

              leftButtonLabel: "Forget password?",
              onLeftButtonPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgetPassword(username: widget.username,)));
              },
            showLeftButton: true,
          )
        ],
      ),
    );
  }
}
