import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-description.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/page-title.dart';
import 'package:gigachat/widgets/username-input-field.dart';

const String CONFIRM_EMAIL_PAGE_DESCRIPTION = "Verify your identity by entering"
    " the email address associated with your " + APP_NAME + " account.";

class ConfirmEmailPage extends StatefulWidget {
  final String username;
  const ConfirmEmailPage({super.key, required this.username});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage>
{
  String? username;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    late String email;

    return Scaffold(
      appBar: LoginAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const PageTitle(title: "Confirm your email"),

            const SizedBox(height: 15),

            const PageDescription(description: CONFIRM_EMAIL_PAGE_DESCRIPTION),

            const SizedBox(height: 20),

            TextDataFormField(onChange: (value){},label: "Email"),

            const Expanded(child: SizedBox()),

            LoginFooter(
                disableNext: false,
                proceedButtonName: "Next",
                onPressed: (){},
                showForgetPassword: false
            )

          ]
        ),
      ),
    );
  }
}
