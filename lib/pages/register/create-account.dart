import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:email_validator/email_validator.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController inputName = TextEditingController();
  TextEditingController inputEmail = TextEditingController();
  TextEditingController inputDOB = TextEditingController();


  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = ThemeProvider();
    bool isDark = theme.getThemeName == "dark";
    Color backGroundColor = theme.getTheme.scaffoldBackgroundColor;
    Color? appBarColor = theme.getTheme.appBarTheme.backgroundColor;
    IconThemeData? appBarIconTheme = theme.getTheme.appBarTheme.iconTheme;
    Color? textFieldBorderColor = theme.getTheme.textTheme.labelSmall?.color;
    MaterialStateProperty<Color?>? buttonBackGroundColor = theme.getTheme.textButtonTheme.style?.backgroundColor;
    MaterialStateProperty<TextStyle?>? buttonTextStyle = theme.getTheme.textButtonTheme.style?.textStyle;
    Color? inputTextColor = theme.getTheme.textTheme.bodyMedium?.color;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: appBarIconTheme,
        toolbarHeight: 40,
        elevation: 0,
        backgroundColor:appBarColor,
        title: Center(
          child: Container(
            height: 40,
            width: 40,
            child: Image.asset(
                isDark ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-dark.png',
              ),
          ),
        ),
      ),
      backgroundColor: backGroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create your account",
              style: TextStyle(
                color: theme.getTheme.textTheme.headlineLarge?.color,
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 100,),
            SizedBox(
              height: 275,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextFormField(
                    style: TextStyle(
                      color: inputTextColor,
                    ),
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textFieldBorderColor!)
                      ),

                    ),
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? input){
                      print(inputEmail.text);
                      if(input != null && !EmailValidator.validate(input)){
                        return "Please enter a valid email";
                      }else {
                        return null;
                      }
                    },
                    style: TextStyle(
                      color: inputTextColor,
                    ),
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textFieldBorderColor)
                      ),
                    ),
                  ),
                  TextFormField(
                    style: TextStyle(
                      color: inputTextColor,
                    ),
                    decoration: InputDecoration(
                      labelText: "Date of birth",
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textFieldBorderColor)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 64,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Divider(thickness: 0.2, color: textFieldBorderColor,),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,10,0),
              child: TextButton(
                  onPressed: (){},
                style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  backgroundColor: buttonBackGroundColor,
                  textStyle: buttonTextStyle,
                  shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      )
                  ),
                ),
                  child: const Text("Next"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
