import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/widgets/input-fields/password-input-field.dart';

import '../../providers/theme-provider.dart';

class CreatePassword extends StatefulWidget {
  const CreatePassword({Key? key}) : super(key: key);

  static const pageRoute = '/create-password';

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {

  TextEditingController inputPassword = TextEditingController();
  bool passwordVisible = false;
  final passwordKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {

    bool isButtonDisabled = inputPassword.text.isEmpty || !passwordKey.currentState!.isValid;

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(null),
        toolbarHeight: 40,
        elevation: 0,
        centerTitle: true,
        title: SizedBox(
          height: 40,
          width: 40,
          child: Image.asset(
            ThemeProvider.getInstance(context).isDark() ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
               "You'll need a password",
               style: TextStyle(
                   fontSize: 30,
                   fontWeight: FontWeight.bold
               ),
             ),
            const SizedBox(height: 10,),
            const Text(
               "Make sure it's 8 characters or more.",
               style: TextStyle(
                 color: Colors.blueGrey,
               ),
             ),
            const SizedBox(height: 15,),
            PasswordFormField(
              onChanged: (String input) async {
                await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                setState(() {});
              },
              label: 'Password',
            ),
            TextFormField(
              key: passwordKey,
              controller: inputPassword,
              autofocus: true,
              style: const TextStyle(
                letterSpacing: 3,
              ),
              obscureText: !passwordVisible,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: InputValidations.isValidPassword,
              onChanged: (String input) async {
                await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: const TextStyle(
                  letterSpacing: 0,
                ),

                border: const OutlineInputBorder(),
                suffixIcon:
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: SizedBox(
                    width: 55,
                    child: Row(
                      children: [
                        const Expanded(child: SizedBox(),),
                        InkWell(
                          child: Icon(
                            passwordVisible?
                            Icons.remove_red_eye_outlined : CupertinoIcons.eye_slash ,
                            color: Colors.blueGrey,),
                          onTap: (){
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                        const SizedBox(width: 5,),
                        inputPassword.text.isEmpty? const SizedBox() : passwordKey.currentState!.isValid?
                        const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
                        const Icon(Icons.error,color: Colors.red,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Divider(thickness: 0.6, height: 1,),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,10,10,0),
              child: ElevatedButton(

                onPressed: isButtonDisabled? null : (){
                  //TODO: register request to api
                  //TODO: navigate to pick a profile page
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      )
                  ),
                ),
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
