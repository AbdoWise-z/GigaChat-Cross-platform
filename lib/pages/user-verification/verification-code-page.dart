import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/forget-password/sub-pages/change-password.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-description.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/page-title.dart';
import 'package:gigachat/widgets/username-input-field.dart';


class VerificationCodePage extends StatefulWidget {
  static String pageRoute = "/verification/code";
  const VerificationCodePage({super.key});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  late String code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoginAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle(title: CODE_VERIFICATION_TITLE),
            const SizedBox(height: 15),
            const PageDescription(description: CODE_VERIFICATION_DESCRIPTION),
            const SizedBox(height: 20),
            TextDataFormField(
                label: "Enter your code",
                onChange: (value){
                  code = value;
                }
            ),
            const Expanded(child: SizedBox()),
            LoginFooter(
              proceedButtonName: "Next",
              showCancelButton: false,
              showForgetPassword: false,
              showBackButton: true,
              onPressed: (){
                // TODO: check for the code here
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder:
                            (context)=>
                            const NewPasswordPage()
                    )
                );
              },
            )

          ],
        ),
      ),
    );
  }
}
