import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';

class ChooseUsername extends StatefulWidget {
  const ChooseUsername({Key? key}) : super(key: key);

  static const pageRoute = '/choose-username';
  @override
  State<ChooseUsername> createState() => _ChooseUsernameState();
}

class _ChooseUsernameState extends State<ChooseUsername> {

  TextEditingController inputUsername = TextEditingController();
  bool usernameIsValid = false;
  bool usernameIsError = false;

  final usernameFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {

    bool isButtonDisabled = inputUsername.text.isEmpty || !usernameFieldKey.currentState!.isValid;

    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: null,
        showDefault: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("What should we call you?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text("Your @username is unique. You can always change it later.",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      key: usernameFieldKey,
                      controller: inputUsername,
                      autofocus: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: InputValidations.isValidUsername,
                      onChanged: (String input) async {
                        await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: "Username",
                        errorMaxLines: 2,
                        border: const OutlineInputBorder(),
                        suffixIcon: inputUsername.text.isEmpty? null :
                        usernameFieldKey.currentState!.isValid?
                        const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
                        const Icon(Icons.error,color: Colors.red,),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: AuthFooter(
        disableRightButton: isButtonDisabled,
        showLeftButton: true,
        leftButtonLabel: "Skip for now",
        rightButtonLabel: "Next",
        onLeftButtonPressed: (){
          //TODO: navigate to follow one person page
        },
        onRightButtonPressed: () async {
          //TODO: request to update username
          //TODO: navigate to follow one person page
        },
      ),
    );
  }
}
