import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/password-input-field.dart';


const String NEW_PASSWORD_DESCRIPTION =
    "Make sure your new password is 8 characters or more. Try including numbers, letters, and punctuation marks for a strong password\n\nYou'll be logged out of all active $APP_NAME sessions after your password is changed.";

class NewPasswordPage extends StatefulWidget {
  NewPasswordPage({super.key, required this.code, required this.email, required this.isLogged});

  String email;
  String code;
  bool isLogged;
  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  late String newPassword;
  late String confirmPassword;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    newPassword = "";
    confirmPassword = "";
  }

  bool _loading = false;
  void _createPassword(String newPassword) async {
    setState(() {
      _loading = true;
    });

    Auth auth = Auth.getInstance(context);

    auth.resetPassword(
      newPassword,
      widget.code,
      success: (res){
        if(widget.isLogged){  //logout

        }else{  //login
          auth.login(
            widget.email,
            newPassword,
              success: (res) {
                Navigator.popUntil(context, (r) => false);
                Navigator.pushNamed(context, Home.pageRoute);
              },
              error: (res){
                Toast.showToast(context,"Failed to login",width: 20);
                Navigator.popUntil(context, (r) => false);
                setState(() {
                  _loading = false;
                });
              }
          );
        }
      },
      error: (res){
        Toast.showToast(context, "API error");
      }
    );

    setState(() {
      _loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    bool isValidForm = (formKey.currentState != null &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        formKey.currentState!.validate()
    );
    return Stack(
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600,
            ),
            child: Scaffold(
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
              body: Padding(
                padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PageTitle(title: "Choose a new password"),
                      const SizedBox(height: 20),
                      const PageDescription(description: NEW_PASSWORD_DESCRIPTION),
                      const SizedBox(height: 20),
                      Form(key: formKey, child: Column(children: [
                        PasswordFormField(
                          onChanged: (value) {
                            setState(() {
                              newPassword = value;
                            });
                          },
                          label: "Enter a new password",
                        ),
                        const SizedBox(height: 20),
                        PasswordFormField(
                          onChanged: (value) {
                            setState(() {
                              confirmPassword = value;
                            });
                          },
                          validator: (value){
                            return value == newPassword ? null : "passwords is not identical";
                          },
                          label: "Confirm password",
                        ),
                      ],)
                      ),
                      const SizedBox(height: 100,)
                    ],
                  ),
                ),
              ),
              bottomSheet: AuthFooter(
                rightButtonLabel: "Change password",
                disableRightButton: !isValidForm,
                onRightButtonPressed: () => _createPassword(newPassword),

                leftButtonLabel: "",
                onLeftButtonPressed: (){},
                showLeftButton: false,
              )
            ),
          ),
        ),
        Visibility(
          visible: _loading,
          child: const Positioned.fill(child: BlockingLoadingPage()),
        ),
      ],
    );
  }
}
