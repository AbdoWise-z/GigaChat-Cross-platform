import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';

import '../../providers/auth.dart';

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
  void initState() {
    super.initState();
    inputUsername.text = Auth.getInstance(context).getCurrentUser()!.id;
  }

  bool _loading = false;
  void _setUsername(String name) async {
    setState(() {
      _loading = true;
    });

    Auth auth = Auth.getInstance(context);
    if (auth.getCurrentUser() == null){
      throw "This should never happen ...";
    }

    auth.setUserUsername(
      name ,
      success: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);


          _loading = false;
          Navigator.popUntil(context, (route) => false);
          Navigator.pushNamed(context, Home.pageRoute);
        });
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
    bool isButtonDisabled = inputUsername.text.isEmpty || usernameFieldKey.currentState == null || !usernameFieldKey.currentState!.isValid || inputUsername.text == Auth.getInstance(context).getCurrentUser()!.id;

    return Stack(
      children: [
        Scaffold(
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
                            suffixIcon: inputUsername.text.isEmpty ? null : (usernameFieldKey.currentState == null || usernameFieldKey.currentState!.isValid) ?
                            const Icon(Icons.check_circle_sharp, color: CupertinoColors.systemGreen,) :
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
              Navigator.popUntil(context, (route) => false);
              Navigator.pushNamed(context, Home.pageRoute);
            },
            onRightButtonPressed: () => _setUsername(inputUsername.text),
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
