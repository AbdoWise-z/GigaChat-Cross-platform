import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/forget-password/change-password.dart';
import 'package:gigachat/pages/register/create-password.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/username-input-field.dart';

const String CODE_VERIFICATION_DESCRIPTION =
    "Check your email to get your confirmation"
    " code. if you need to request a new code, go back and reselect confirmation";

class VerificationCodePage extends StatefulWidget {
  static String pageRoute = "/verification/code";

  bool isRegister;
  ContactMethod method;
  VerificationCodePage({super.key, required this.isRegister , required this.method});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  late String code;
  late bool valid;
  bool resendEmailIsEnabled = false;
  int counter = 60;

  @override
  void initState() {
    super.initState();
    code = "";
    valid = false;
    enableResendEmail();
  }

  void enableResendEmail() async {
    for(int i = 60; i >= 1; i--){
      if (!context.mounted){
        return;
      }
      setState(() {
        counter = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() {
      resendEmailIsEnabled = true;
    });
  }

  bool _loading = false;
  void _requestVerify(ContactMethod m) async {
    setState(() {
      _loading = true;
    });

    await Auth.getInstance(context).requestVerificationMethod(m , () {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerificationCodePage(isRegister: false,method: m,)));
    });

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    String email = widget.isRegister ? ModalRoute.of(context)?.settings.arguments as String : "";
    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: widget.isRegister ? null: IconButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          icon: const Icon(Icons.close),
        ),
        showDefault: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle(title: "We sent you a code"),
            const SizedBox(height: 15),
            PageDescription(description: widget.isRegister ? "Enter it below to verify $email." : CODE_VERIFICATION_DESCRIPTION),
            const SizedBox(height: 20),
            TextDataFormField(
                keyboardType: widget.isRegister? TextInputType.number : TextInputType.text,
                label: "Enter your code",
                onChange: (value) {
                  setState(() {
                    code = value;
                    valid = value.isNotEmpty;
                  });
                }),
            const SizedBox(height: 25,),
            GestureDetector(
              onTap: resendEmailIsEnabled && !_loading ? (){
                //TODO: send confirmation code request
                setState(() {
                  resendEmailIsEnabled = false;
                  enableResendEmail();
                });
              } : null,
              child: Text(
                resendEmailIsEnabled? "Resend email?": "Resend email after ($counter)sec",
                style: TextStyle(
                    color: resendEmailIsEnabled && !_loading ? Colors.blue : Colors.grey
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
            AuthFooter(
              rightButtonLabel: "Next",
              disableRightButton: !valid,
              onRightButtonPressed: (){
                widget.isRegister ? (){
                  // TODO: call the api here
                  Navigator.pushReplacementNamed(context, CreatePassword.pageRoute);
                } :
                Navigator.push(
                    context,
                    // TODO: call the api here
                    MaterialPageRoute(builder: (context) => const NewPasswordPage()));
              },

              leftButtonLabel: "Back",
              onLeftButtonPressed: (){
                Navigator.pop(context);
              },
              showLeftButton: !widget.isRegister,
            )
          ],
        ),
      ),
    );
  }
}
