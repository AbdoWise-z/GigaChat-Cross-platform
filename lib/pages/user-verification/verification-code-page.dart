import 'package:flutter/material.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/forget-password/change-password.dart';
import 'package:gigachat/pages/register/create-password.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/username-input-field.dart';

import '../home/home.dart';

const String CODE_VERIFICATION_DESCRIPTION =
    "Check your email to get your confirmation"
    " code.";

class VerificationCodePage extends StatefulWidget {
  static String pageRoute = "/verification/code";

  bool isRegister;
  bool isVerify;
  bool isLogged;
  ContactMethod method;
  VerificationCodePage({super.key, required this.isRegister , required this.method,required this.isVerify, required this.isLogged});

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

  bool _resendLoading = false;
  void _requestCode(ContactMethod m) async {
    setState(() {
      _resendLoading = true;
      resendEmailIsEnabled = false;
      counter = 60;
    });

    Auth auth = Auth.getInstance(context);

    widget.isRegister || widget.isVerify?  auth.requestVerificationMethod(
      m ,
      success: (res) {
        setState(() {
          _resendLoading = false;
          resendEmailIsEnabled = false;
          enableResendEmail();
        });
      },
      error: (res) {
        setState(() {
          _resendLoading = false;
          resendEmailIsEnabled = true;
        });
      },
    ) : auth.forgotPassword(
      m,
      success: (res){
        setState(() {
          _resendLoading = false;
          resendEmailIsEnabled = false;
          enableResendEmail();
        });
      },
      error: (res){
        setState(() {
          _resendLoading = false;
          resendEmailIsEnabled = true;
        });
      },
    );
  }

  bool _loading = false;
  void _verifyCode(ContactMethod m , String code) async {
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
    });

    Auth auth = Auth.getInstance(context);

    widget.isRegister || widget.isVerify? await auth.verifyMethod(
      m,
      code,
      auth.getCurrentUser() != null? auth.getCurrentUser()!.auth : null,
      widget.isVerify,
      success: (res) {
        if(widget.isVerify && widget.isRegister){
          Navigator.popUntil(context, (route) => false);
          Navigator.pushNamed(context, Home.pageRoute);
        }
        else if (widget.isRegister){
          Navigator.pushReplacementNamed(context, CreatePassword.pageRoute);
        }
      },
      error: (res) {
        print(res.code);
        print(res.responseBody);
        if (res.code == ApiResponse.CODE_NOT_AUTHORIZED){
          Toast.showToast(context, "Wrong code");
        }
      },
    ) :
    auth.checkForgotPasswordCode(
      code,
      success: (res){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                NewPasswordPage(code: code, email: widget.method.data!,isLogged: widget.isLogged,)
            )
        );
      },
      error: (res){
        print(res.code);
        print(res.responseBody);
        if (res.code == ApiResponse.CODE_BAD_REQUEST){
          Toast.showToast(context, "Wrong code");
        }
      }
    );

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading){
      return const BlockingLoadingPage();
    }

    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: widget.isRegister ? null: IconButton(
          onPressed: () {
            widget.isLogged? Navigator.pop(context) :
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          icon: const Icon(Icons.close),
        ),
        showDefault: false,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle(title: "We sent you a code"),
                const SizedBox(height: 15),
                PageDescription(description: widget.isRegister ? "Enter it below to verify ${widget.method.data}." : CODE_VERIFICATION_DESCRIPTION),
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

                Row(
                  children: [
                    GestureDetector(
                      onTap: resendEmailIsEnabled && !_resendLoading ? () => _requestCode(widget.method) : null,
                      child: Text(
                        resendEmailIsEnabled? "Resend email?": "Resend email after ($counter)sec",
                        style: TextStyle(
                            color: resendEmailIsEnabled && !_resendLoading ? Colors.blue : Colors.grey
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Visibility(
                      visible: _resendLoading,
                      child: const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const Expanded(child: SizedBox()),
                AuthFooter(
                  rightButtonLabel: "Next",
                  disableRightButton: !valid,
                  onRightButtonPressed: () => _verifyCode(widget.method , code),

                  leftButtonLabel: "Back",
                  onLeftButtonPressed: (){
                    Navigator.pop(context);
                  },
                  showLeftButton: !widget.isRegister,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
