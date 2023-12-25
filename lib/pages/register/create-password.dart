import 'package:flutter/material.dart';
import 'package:gigachat/pages/setup-profile/setup-profile-picture.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/input-fields/password-input-field.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import '../blocking-loading-page.dart';


class CreatePassword extends StatefulWidget {
  const CreatePassword({Key? key}) : super(key: key);

  static const pageRoute = '/create-password';

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  String? inputPassword;
  bool passwordVisible = false;
  final passwordKey = GlobalKey<FormFieldState>();

  bool _loading = false;
  void _createPassword(String newPassword) async {
    setState(() {
      _loading = true;
    });

    Auth auth = Auth.getInstance(context);
    if (auth.getCurrentUser() == null){
      throw "This should never happen ...";
    }

    auth.createNewUserPassword(
      newPassword ,
      success: (res) async {
        await auth.login(
            auth.getCurrentUser()!.email,
            newPassword,
            success: (res) {
              setState(() {
                print(res.code);
                print(res.responseBody);

                _loading = false;
                Navigator.pushReplacementNamed(context, PickProfilePicture.pageRoute);
              });
            },
            error: (res){
              throw "WTF ??";
            }
        );
      },
      error: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);

          _loading = false;
          Toast.showToast(context, "API Error ..");
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonDisabled = inputPassword != null &&
        (inputPassword!.isEmpty || !passwordKey.currentState!.isValid);

    return Stack(
      children: [
        Scaffold(
          appBar: AuthAppBar(context, leadingIcon: null, showDefault: false),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "You'll need a password",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Make sure it's 8 characters or more.",
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 15),
                PasswordFormField(
                  passwordKey: passwordKey,
                  onChanged: (String input) async {
                    inputPassword = input;
                    await Future.delayed(
                        const Duration(milliseconds: 50)); //wait for validator
                    setState(() {});
                  },
                  label: 'Password',
                ),
              ],
            ),
          ),
          bottomSheet: AuthFooter(
              disableRightButton: isButtonDisabled,
              showLeftButton: false,
              leftButtonLabel: "",
              rightButtonLabel: "Next",
              onLeftButtonPressed: () {},
              onRightButtonPressed: () => _createPassword(inputPassword!)
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
