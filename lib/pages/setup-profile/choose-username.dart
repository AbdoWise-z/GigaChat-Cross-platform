import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../providers/theme-provider.dart';
import 'package:gigachat/services/input-verifications.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      controller: inputUsername,
                      autofocus: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? input){
                        if(input == null || input.isEmpty){
                          usernameIsError = false;
                          usernameIsValid = false;
                          return null;
                        }
                        else if(input.length > 15 || !InputVerification.verifyUsername(inputUsername.text)){
                          usernameIsValid = false;
                          usernameIsError = true;
                          return "Your username must be 15 characters or less and contain"
                              " only letters, numbers, and underscores and no spaces";
                        }
                        else if(input.length <= 4){
                          usernameIsValid = false;
                          usernameIsError = true;
                          return "Username should be more than 4 characters.";
                        }
                        else{
                          usernameIsValid = true;
                          usernameIsError = false;
                          return null;
                        }
                      },
                      onChanged: (String input) async {
                        await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: "Username",
                        errorMaxLines: 2,
                        border: const OutlineInputBorder(),
                        suffixIcon: usernameIsValid?
                        const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
                        usernameIsError? const Icon(Icons.error,color: Colors.red,) : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              padding: const EdgeInsets.fromLTRB(10,10,10,0),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: (){
                      //navigate to username page
                      Navigator.pushReplacementNamed(context, ChooseUsername.pageRoute);
                    },
                    style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        )
                    ),
                    child: const Text("Skip for now"),
                  ),
                  const Expanded(child: SizedBox()),
                  ElevatedButton(
                    onPressed: usernameIsValid? () async {
                      //TODO: request to update username
                      //TODO: navigate to follow one person page
                      //Navigator.pushReplacementNamed(context, ChooseUsername.pageRoute);
                    } : null,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          )
                      ),
                    ),
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
