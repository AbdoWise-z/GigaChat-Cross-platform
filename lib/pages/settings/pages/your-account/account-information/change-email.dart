import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/user-verification/verification-code-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';

import '../../../../../util/Toast.dart';
import '../../../../../widgets/text-widgets/main-text.dart';
import '../../../../../widgets/text-widgets/page-title.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({Key? key}) : super(key: key);
  static const pageRoute = '/change-email';

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {

  bool isButtonDisabled = true;
  late final Auth authProvider;
  TextEditingController inputEmail = TextEditingController();
  bool loading = false;
  final emailFieldKey = GlobalKey<FormFieldState>();

  void changeEmail(String email) async {
    setState(() {
      loading = true;
    });

    Auth auth = Auth.getInstance(context);
    auth.changeUserEmail(
      email ,
      success: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);
          loading = false;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) =>
                  VerificationCodePage(
                      isRegister: true,
                      isVerify: true,
                      isLogged: true,
                      method: ContactMethod(
                          method: ContactMethodType.EMAIL,
                          data: email,
                          title: "",
                          disc: ""
                      )
                  )
          ));
        });
      },
      error: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);
          if(res.code == 404){
            Toast.showToast(context, "This email address is unavailable");
          } else{
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
    isButtonDisabled =  !(emailFieldKey.currentState != null && emailFieldKey.currentState!.isValid)
        || inputEmail.text.isEmpty || inputEmail.text == authProvider.getCurrentUser()!.email;
    return loading == true? const BlockingLoadingPage() :
    Scaffold(
      appBar: AuthAppBar(context, leadingIcon: null, showDefault: true,),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // page Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle(title: "Change email"),
                const SizedBox(height: 15),
                MainText(
                  text: "Your current email is ${authProvider.getCurrentUser()!.email}."
                      " What would you like to update it to? "
                      "Your email is not displayed in your public profile on Gigachat",
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: emailFieldKey,
                  controller: inputEmail,
                  autofocus: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: InputValidations.isValidEmail,
                  onChanged: (String input) async {
                    setState(() {
                      isButtonDisabled = true;
                    });
                    await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      labelText: "Email address",
                      border: const OutlineInputBorder(),
                      suffixIcon: inputEmail.text.isEmpty? null :
                      (emailFieldKey.currentState == null || emailFieldKey.currentState!.isValid)?
                      const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
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
        onRightButtonPressed: () => changeEmail(inputEmail.text),
        leftButtonLabel: "Cancel",
        onLeftButtonPressed: (){
          Navigator.pop(context);
        },
        showLeftButton: true,
      )
    );
  }
}
