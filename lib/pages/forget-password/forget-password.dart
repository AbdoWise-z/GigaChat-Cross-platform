import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/forget-password/confirm-email.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-description.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/page-title.dart';
import 'package:gigachat/widgets/username-input-field.dart';
import '../user-verification/select-verification-method-page.dart';


List<ContactMethod> getUserContactMethods(String email)
{
  // TODO: move this function to its folder & implement dealing with api
  // TODO: email must be hidden by stars
  return [
    ContactMethod(contactWay: "Send an email to", contactTarget: email),
    ContactMethod(contactWay: "Send an email to", contactTarget: email),

    ContactMethod(contactWay: "Send an email to", contactTarget: email),

    ContactMethod(contactWay: "Send an email to", contactTarget: email),

    ContactMethod(contactWay: "Send an email to", contactTarget: email),

    ContactMethod(contactWay: "Send an email to", contactTarget: email),

    ContactMethod(contactWay: "Send an email to", contactTarget: email),


  ];
}

const String FORGET_PASSWORD_DESCRIPTION = "Enter the email, phone number, or "
    "username associated with your account to change the password.";


class ForgetPassword extends StatefulWidget {
  static const String pageRoute = "/forget-password";

  String? username;
  ForgetPassword({super.key,this.username});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String? username;
  String? email;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.username;
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
            const PageTitle(title: "Find your GIGACHAT account"),

            const SizedBox(height: 10),

            const PageDescription(description: FORGET_PASSWORD_DESCRIPTION),

            const SizedBox(height: 20),

            TextDataFormField(onChange: (email){
              this.email = email;
            }, value: username),

            const Expanded(child: SizedBox()),

            LoginFooter(proceedButtonName: "Next",
                onPressed: (){
                  Navigator.pushReplacement(context,
                      //MaterialPageRoute(builder: (context)=> ConfirmEmailPage(username: "a",))
                      MaterialPageRoute(
                          builder: (context)=> VerificationMethodPage(methods: getUserContactMethods("koko"))
                      )
                  );
                },
                showForgetPassword: false)
          ],
        ),
      ),
    );
  }
}
