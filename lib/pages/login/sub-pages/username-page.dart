import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/page-title.dart';
import 'package:gigachat/widgets/username-input-field.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';

class UsernameLoginPage extends StatefulWidget {
  const UsernameLoginPage({super.key});

  @override
  State<UsernameLoginPage> createState() => _UsernamePageState();
}

const String LOGIN_PAGE_DESCRIPTION =
    "To get started, first enter your phone, email, or @username";

class _UsernamePageState extends State<UsernameLoginPage> {
  late String username;
  late bool isValid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = "";
    isValid = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoginAppBar(context),
      body: Column(
        children: [
          // Page Title
          Padding(
            padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
            child: Column(
              children: [
                const PageTitle(title: LOGIN_PAGE_DESCRIPTION),
                // Empty Space
                const SizedBox(height: 20),
                // Username Input Field
                TextDataFormField(
                    validator: InputValidations.verifyUsername,
                    onChange: (editedUsername) {
                      setState(() {
                        username = editedUsername;
                        isValid = InputValidations.verifyUsername(username) == null;
                      });
                    }
                ),
              ],
            ),
          ),
          // Empty Space
          const Expanded(child: SizedBox()),
          // Page Footer
          LoginFooter(
            disableNext: !isValid,
            proceedButtonName: "Next",
            onPressed: () async {
            if (InputValidations.verifyUsername(username) == null)
            {
              Navigator.pushReplacement(
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
    );
  }
}
