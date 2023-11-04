import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/forget-password/change-password.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/input-fields/username-input-field.dart';


const String CODE_VERIFICATION_DESCRIPTION = "Check your email to get your confirmation"
    " code. if you need to request a new code, go back and reselect confirmation";

class VerificationCodePage extends StatefulWidget {
  static String pageRoute = "/verification/code";
  const VerificationCodePage({super.key});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  late String code;
  late bool valid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    code = "";
    valid = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoginAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle(title: "We sent you a code"),
            const SizedBox(height: 15),
            const PageDescription(description: CODE_VERIFICATION_DESCRIPTION),
            const SizedBox(height: 20),
            TextDataFormField(
                label: "Enter your code",
                onChange: (value){
                  setState(() {
                    code = value;
                    valid = InputValidations.isValidCode(value) == null;
                  });
                }
            ),
            const Expanded(child: SizedBox()),
            LoginFooter(
              disableNext: !valid,
              proceedButtonName: "Next",
              showCancelButton: false,
              showForgetPassword: false,
              showBackButton: true,
              onPressed: (){
                // TODO: check for the code here
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context)=> const NewPasswordPage())
                );
              },
            )

          ],
        ),
      ),
    );
  }
}
