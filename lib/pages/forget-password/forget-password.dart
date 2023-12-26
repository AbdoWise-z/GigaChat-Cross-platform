import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/forget-password/confirm-email.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/username-input-field.dart';
import '../user-verification/select-verification-method-page.dart';

const String FORGET_PASSWORD_DESCRIPTION = "Enter the email, phone number, or "
    "username associated with your account to change the password.";

class ForgetPassword extends StatefulWidget {
  static const String pageRoute = "/forget-password";

  String? username;
  bool isLogged;

  ForgetPassword({super.key, this.username, required this.isLogged});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  late String email;
  late bool valid;

  @override
  void initState() {
    super.initState();
    email = widget.username ?? "";
    valid = email.isNotEmpty;
  }

  bool _loading = false;
  void _getContactMethods() async {
    if (InputValidations.isValidEmail(email) == null) {
      setState(() {
        _loading = true;
      });

      var methods = await Auth.getInstance(context).getContactMethods(email , (m) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(
            builder: (context) =>
                VerificationMethodPage(
                  isLogged: false,
                  methods: m
                ),
          ),
        );
      });
      if (methods == null){
        setState(() {
          _loading = false;
        });
        return;
      }
    }else{
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConfirmEmailPage(username: email,isLogged: widget.isLogged,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const BlockingLoadingPage();
    }

    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: IconButton(
          onPressed: () {
            widget.isLogged? Navigator.pop(context) :
              Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          icon: const Icon(Icons.close),
        ),
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
                const PageTitle(title: "Find your GIGACHAT account"),
                const SizedBox(height: 10),
                const PageDescription(description: FORGET_PASSWORD_DESCRIPTION),
                const SizedBox(height: 20),
                TextDataFormField(
                    onChange: (value) {
                      setState(() {
                        email = value;
                        valid = value.isNotEmpty;
                      });
                    },
                    value: email
                ),
                const Expanded(child: SizedBox()),

                AuthFooter(
                  rightButtonLabel: "Next",
                  disableRightButton: !valid,
                  onRightButtonPressed: _getContactMethods,

                  leftButtonLabel: "",
                  onLeftButtonPressed: (){},
                  showLeftButton: false,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
