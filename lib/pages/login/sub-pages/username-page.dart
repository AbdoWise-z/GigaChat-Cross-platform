import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/username-input-field.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';

class UsernameLoginPage extends StatefulWidget {
  static const String pageRoute = "/login/username";
  static const String inputFieldKey = "username-page-input-field";
  static const String nextButtonKey = "username-page-next-button";

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
    super.initState();
    username = "";
    isValid = false;
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
                    key: const Key(UsernameLoginPage.inputFieldKey),
                    onChange: (editedUsername) {
                      setState(() {
                        username = editedUsername;
                        isValid = username.isNotEmpty;
                      });
                    }),
              ],
            ),
          ),
          // Empty Space
          const Expanded(child: SizedBox()),
          // Page Footer
          AuthFooter(
            rightButtonKey: const Key(UsernameLoginPage.nextButtonKey),

            rightButtonLabel: "Next",
            disableRightButton: !isValid,
            onRightButtonPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordLoginPage(username: username)));
            },

            leftButtonLabel: "Forget password?",
            onLeftButtonPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgetPassword(username: "", isLogged: false,)));
            },
            showLeftButton: true,
          )
        ],
      ),
    );
  }
}
