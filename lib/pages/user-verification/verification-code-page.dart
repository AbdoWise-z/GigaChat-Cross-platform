import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoginAppBar(),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle(title: CODE_VERIFICATION_TITLE),
            const SizedBox(height: 15),
            const PageDescription(description: CODE_VERIFICATION_DESCRIPTION),
            const SizedBox(height: 20),
            UsernameFormField(label: "Enter your code",onChange: (){}),
            const Expanded(child: SizedBox()),
            LoginFooter(
              proceedButtonName: "Next",
              showCancelButton: false,
              showForgetPassword: false,
              showBackButton: true,
            )

          ],
        ),
      ),
    );
  }
}
