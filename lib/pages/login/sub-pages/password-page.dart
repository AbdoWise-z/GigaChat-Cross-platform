import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/password-input-field.dart';

class PasswordLoginPage extends StatefulWidget {
  static const String pageRoute = "/login/password";
  static final passwordFieldKey = GlobalKey<FormFieldState>();
  static const loginButtonKey = "login-password-login-button";

  final String username;

  const PasswordLoginPage({required this.username, super.key});

  @override
  State<PasswordLoginPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<PasswordLoginPage> {
  String? password;
  bool isValid = false;
  late bool logInPressed;
  late final Auth authProvider;
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    password = "";
    authProvider = Auth.getInstance(context);
    logInPressed = false;
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {

    checkForLoginFailure();


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
                  passwordKey: PasswordLoginPage.passwordFieldKey,
                  hideBorder: true,
                  onChanged: (value) {
                    setState(() {
                      logInPressed = false;
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
            onRightButtonPressed: () async {
              authProvider.login(widget.username, password!);
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

  _showToast(String message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(message),],
      ),
    );


    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }


  void checkForLoginFailure() async {
      await Future.delayed(const Duration(milliseconds: 80));
      if(authProvider.loginState == LoginState.success){
        _showToast("Wrong password!");
      }
      authProvider.resetLoginState();
  }
}
