import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/widgets/auth/input-fields/password-input-field.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';


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

  @override
  Widget build(BuildContext context) {
    bool isButtonDisabled = inputPassword != null &&
        (inputPassword!.isEmpty || !passwordKey.currentState!.isValid);

    return Scaffold(
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
          onLeftButtonPressed: (){},
          onRightButtonPressed: (){
            //TODO: register request to api
            //TODO: navigate to pick a profile page
          }
      ),
     );
  }
}
