import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/login/controllers/password-controller.dart';
import 'package:gigachat/pages/login/shared-widgets/forget-password-button.dart';
import 'package:gigachat/pages/login/shared-widgets/login-app-bar.dart';
import 'package:gigachat/pages/login/shared-widgets/page-footer.dart';

import '../shared-widgets/username-input-field.dart';


class PasswordLoginPage extends StatefulWidget {
  String? username;

  PasswordLoginPage({this.username,super.key});


  @override
  State<PasswordLoginPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<PasswordLoginPage> {
  String? username = "";
  bool passwordVisible = false;
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
    IconData passwordState =
    passwordVisible ?
    Icons.visibility_outlined :
    Icons.visibility_off_outlined;

    return Theme(
        data: ThemeData(
            brightness: Brightness.dark,
          disabledColor: const Color(0xffFAFAFA)
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: LoginAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // page description
                const Text(PASSWORD_PAGE_DESCRIPTION,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                  ),
                  textAlign: TextAlign.left,
                ),

                // empty space
                const SizedBox(height: 30),

                // username input field - disabled -
                UsernameFormField(onChange: (email){}, value: username, isEnabled: false),

                // empty space
                const SizedBox(height: 20),

                // password field
                TextFormField(
                  onChanged: (editedPassword){
                    setState(() {
                      password = editedPassword;
                    });
                  },
                  obscureText: ! passwordVisible,
                  autocorrect: false,
                  enableSuggestions: false,

                  decoration: InputDecoration(
                      label:  const Text(PASSWORD_INPUT_LABEL),
                      border: const OutlineInputBorder(),
                      suffixIcon:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // hide and show password
                            SizedBox(
                              width:50,
                              child: ElevatedButton(
                                  onPressed: (){
                                    setState(() {
                                      passwordVisible = ! passwordVisible;
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                             return Colors.transparent;
                                          },
                                    ),
                                  ),
                                  child: Icon(passwordState)
                              ),
                            ),

                            // verification Icon
                            Visibility(
                              visible: password!.length >= 5,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.check_circle_rounded,color: Colors.green),
                              ),
                            )
                          ],
                        ),
                      ),
                  ),

                const Expanded(child: SizedBox()),

                LoginFooter(proceedButtonName: "Log in",username: this.username)
              ],
            ),
          ),
        )
    );
  }
}
