import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/input-fields/password-input-field.dart';



class PasswordLoginPage extends StatefulWidget {
  String username;

  PasswordLoginPage({required this.username,super.key});


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

      appBar: LoginAppBar(context),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey,width: 0.5),
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(widget.username,),
                      ),
                    ),
                  ],
                ),

                // empty space
                const SizedBox(height: 20),

                // password field
                PasswordFormField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                      isValid = InputValidations.verifyPassword(password) == null;
                    });
                    },
                  validator: InputValidations.verifyPassword,
                  label: "Password",
                ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),

          LoginFooter(
              disableNext: !isValid,
              proceedButtonName: "Log in",
              username: widget.username
          )
        ],
      ),
    );
  }
}
