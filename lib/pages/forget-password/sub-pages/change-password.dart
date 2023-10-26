import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-description.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/page-title.dart';
import 'package:gigachat/widgets/password-input-field.dart';
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
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
              const PageTitle(title: NEW_PASSWORD_TITLE),
              const SizedBox(height: 20),
              const PageDescription(description: NEW_PASSWORD_DESCRIPTION),
              const SizedBox(height: 20),
              PasswordFormField(
                onChanged: (value){},
                validator: (value){return value.length > 5;},
                label: "Password",
              ),
              const SizedBox(height: 20),
              PasswordFormField(
                  onChanged: (value){
                // TODO: check if the password is the same
              },
                validator: (value){return value.length > 5;},
                label: "Confirm password",
              ),
            ],
          ),
        ),
      ),
      bottomSheet: LoginFooter(
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
