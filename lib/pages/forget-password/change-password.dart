import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-description.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/page-title.dart';
import 'package:gigachat/widgets/password-input-field.dart';

const String NEW_PASSWORD_DESCRIPTION = "Make sure your new password is 8 characters or more. "
    "Try including numbers, letters, and punctuation marks for a strong password"
    "\n\nYou'll be logged out of all active " + APP_NAME + " sessions after your password is changed.";

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  late String newPassword;
  late String confirmPassword;
  late bool validInput;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    newPassword = "";
    confirmPassword = "";
    validInput = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoginAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageTitle(title: "Choose a new password"),
              const SizedBox(height: 20),
              const PageDescription(description: NEW_PASSWORD_DESCRIPTION),
              const SizedBox(height: 20),
              PasswordFormField(
                onChanged: (value){
                  setState(() {
                    newPassword = value;
                    validInput = InputValidations.verifyPassword(value) == null;
                    validInput = validInput && newPassword == confirmPassword;
                  });
                },
                validator: InputValidations.verifyPassword,
                //validator: (value){return value.length > 5;},
                label: "Password",
              ),
              const SizedBox(height: 20),
              PasswordFormField(
                  validator: InputValidations.verifyPassword,
                  onChanged: (value){
                    setState(() {
                      confirmPassword = value;
                      validInput = InputValidations.verifyPassword(value) == null;
                      validInput = validInput && newPassword == confirmPassword;
                    });
                  },
                //validator: (value){return value.length > 5;},
                label: "Confirm password",
              ),
            ],
          ),
        ),
      ),
      bottomSheet: LoginFooter(
        disableNext: !validInput,
        proceedButtonName: "Change password",
        showBackButton: false,
        showForgetPassword: false,
        showCancelButton: false,
        onPressed: (){
          // TODO: call api to change the password
        },
      ),
    );
  }
}
