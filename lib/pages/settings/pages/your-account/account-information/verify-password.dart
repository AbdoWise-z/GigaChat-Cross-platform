import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-information/change-email.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/main-text.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/password-input-field.dart';

class VerifyPasswordPage extends StatefulWidget {
  static const String pageRoute = "/verify-password";

  const VerifyPasswordPage({super.key});

  @override
  State<VerifyPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<VerifyPasswordPage> {
  bool isButtonDisabled = true;
  late final Auth authProvider;
  TextEditingController inputPassword = TextEditingController();
  bool loading = false;
  final passwordFieldKey = GlobalKey<FormFieldState>();


  void verifyPassword(String password) async {
    setState(() {
      loading = true;
    });

    Auth auth = Auth.getInstance(context);
    auth.verifyUserPassword(
      password ,
      success: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);
          loading = false;
          Navigator.pushReplacementNamed(context, ChangeEmailPage.pageRoute);
        });
      },
      error: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);
          if(res.code == 401){
            Toast.showToast(context, "Password is incorrect.");
          }else{
            Toast.showToast(context, "API Error ..");
          }
          loading = false;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    authProvider = Auth.getInstance(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading){
      return const BlockingLoadingPage();
    }
    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: null,
        showDefault: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // page Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle(title: "Verify your password"),
                const SizedBox(height: 15),
                const MainText(text: "Re-enter your Gigachat password to continue.",color: Colors.blueGrey,),
                const SizedBox(height: 20),
                TextFormField(
                  key: passwordFieldKey,
                  controller: inputPassword,
                  autofocus: true,
                  validator: (value){
                    if(InputValidations.isValidPassword(value) is String){
                      isButtonDisabled = true;
                      return "Invalid password";
                    }else {
                      isButtonDisabled = false;
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (String input) async {
                    setState(() {
                      isButtonDisabled = true;
                    });
                    await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: inputPassword.text.isEmpty? null :
                      (passwordFieldKey.currentState == null || passwordFieldKey.currentState!.isValid)? const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
                      const Icon(Icons.error,color: Colors.red,)
                  ),
                )
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
      bottomSheet: AuthFooter(
        rightButtonLabel: "Next",
        disableRightButton: isButtonDisabled,
        onRightButtonPressed: () => verifyPassword(inputPassword.text),
        leftButtonLabel: "Cancel",
        onLeftButtonPressed: (){
          Navigator.pop(context);
        },
        showLeftButton: true,
      ),
    );
  }
}
