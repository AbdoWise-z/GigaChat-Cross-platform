
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  //input controllers
  TextEditingController inputName = TextEditingController();
  TextEditingController inputEmail = TextEditingController();
  TextEditingController inputDOB = TextEditingController();
  //input validation
  bool nameIsValid = false;
  bool nameIsError = false;
  bool emailIsValid = false;
  bool emailIsError = false;
  final formKey = GlobalKey<FormState>();

  FocusNode dateFocusNode = FocusNode();  //to check for date text_field focus

  @override
  Widget build(BuildContext context) {

    ThemeProvider theme = ThemeProvider();
    bool isDark = theme.getThemeName == "dark";
    bool isButtonDisabled = inputDOB.text.isEmpty || inputName.text.isEmpty || inputEmail.text.isEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 40,
        elevation: 0,
        title: Center(
          child: SizedBox(
            height: 40,
            width: 40,
            child: Image.asset(
                isDark ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-dark.png',
              ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0,0,0,50),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                Visibility(
                  visible: MediaQuery.of(context).viewInsets.bottom == 0,  //visible when keyboard is not shown
                    child: const SizedBox(height: 130,)
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,10,0,50),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: inputName,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? input){
                            if(input == null || input.isEmpty){
                              nameIsValid = false;
                              nameIsError = false;
                              return null;
                            }
                            else if(input.length > 50){
                              nameIsValid = false;
                              nameIsError = true;
                              return "Must be 50 characters or fewer";
                            }else{
                              nameIsValid = true;
                              nameIsError = false;
                              return null;
                            }
                          },
                          onChanged: (String input) async {
                            await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: "Name",
                            counterText: "${inputName.text.length}/50",
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(),
                            suffixIcon: nameIsValid?
                            const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
                            nameIsError? const Icon(Icons.error,color: Colors.red,) : null,
                          ),
                        ),
                        const SizedBox(height: 24,),
                        TextFormField(
                          controller: inputEmail,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? input){
                            if(input == null || input.isEmpty){
                              emailIsValid = false;
                              emailIsError = false;
                              return null;
                            }
                            if(EmailValidator.validate(input)){
                              emailIsError = false;
                              emailIsValid = true;
                              return null;
                            }
                            else{
                              emailIsError = true;
                              emailIsValid = false;
                              return "Please enter a valid email";
                            }
                          },
                          onChanged: (String input) async {
                            await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(),
                            suffixIcon: emailIsValid? const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
                            emailIsError? const Icon(Icons.error,color: Colors.red,) : null,
                          ),
                        ),
                        const SizedBox(height: 24,),
                        TextFormField(
                          controller: inputDOB,
                          readOnly: true,
                          focusNode: dateFocusNode,
                          onTap: (){
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            labelText: "Date of birth",
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            ),
          ),
        ),
      ),
      bottomSheet: SizedBox(
        height: dateFocusNode.hasFocus? 150 : 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Divider(thickness: 0.2, height: 1,),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,10,0),
              child: TextButton(

                onPressed: isButtonDisabled? null : (){
                  if(formKey.currentState!.validate()){
                    //TODO: back-end post request
                    //TODO: Navigate to other pages
                    showDialog(context: context,
                        builder: (context) => const Text("Noice")
                    );
                  }
                },
                style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      )
                  ),
                ),
                child: const Text("Next"),
              ),
            ),
            Visibility(
              visible: dateFocusNode.hasFocus,  //visible when date text_field is focused
              child: SizedBox(
                height: 100,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (input){
                    setState(() {
                      inputDOB.text = DateFormat.yMMMMd('en_US').format(input);
                    });
                  },
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
