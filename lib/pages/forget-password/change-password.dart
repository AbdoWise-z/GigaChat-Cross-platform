import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/password-input-field.dart';

const String NEW_PASSWORD_DESCRIPTION =
    "Make sure your new password is 8 characters or more. Try including numbers, letters, and punctuation marks for a strong password\n\nYou'll be logged out of all active $APP_NAME sessions after your password is changed.";

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  late String newPassword;
  late String confirmPassword;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    newPassword = "";
    confirmPassword = "";
  }

  @override
  Widget build(BuildContext context) {
    bool isValidForm = (formKey.currentState != null &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        formKey.currentState!.validate()
    );
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
              Form(key: formKey, child: Column(children: [
                PasswordFormField(
                  onChanged: (value) {
                    setState(() {
                      newPassword = value;
                    });
                  },
                  label: "Enter a new password",
                ),
                const SizedBox(height: 20),
                PasswordFormField(
                  onChanged: (value) {
                    setState(() {
                      confirmPassword = value;
                    });
                  },
                  validator: (value){
                    return value == newPassword ? null : "passwords is not identical";
                  },
                  label: "Confirm password",
                ),
              ],))
            ],
          ),
        ),
      ),
      bottomSheet: AuthFooter(
        rightButtonLabel: "Change password",
        disableRightButton: !isValidForm,
        onRightButtonPressed: (){
          // TODO: call api to change the password
        },

        leftButtonLabel: "",
        onLeftButtonPressed: (){},
        showLeftButton: false,
      )
    );
  }
}
