
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/pages/register/create-password.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/widgets/auth-app-bar.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:intl/intl.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);
  static const pageRoute = "/create-account";
  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  //input controllers
  TextEditingController inputName = TextEditingController();
  TextEditingController inputEmail = TextEditingController();
  TextEditingController inputDOB = TextEditingController();
  //input validation
  final formKey = GlobalKey<FormState>();
  final nameFieldKey = GlobalKey<FormFieldState>();
  final emailFieldKey = GlobalKey<FormFieldState>();


  FocusNode dateFocusNode = FocusNode();  //to check for date text_field focus

  @override
  Widget build(BuildContext context) {

    bool isButtonDisabled = inputDOB.text.isEmpty || inputName.text.isEmpty
        || inputEmail.text.isEmpty || !formKey.currentState!.validate();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AuthAppBar(context, leadingIcon: null,showDefault: true),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,50),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create your account",
                        style: TextStyle(
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
                                key: nameFieldKey,
                                controller: inputName,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: InputValidations.isValidName,
                                onChanged: (String input) async {
                                  await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  labelText: "Name",
                                  border: const OutlineInputBorder(),
                                  counterText: "${inputName.text.length}/50",
                                  suffixIcon: inputName.text.isEmpty? null :
                                    nameFieldKey.currentState!.isValid? const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
                                          const Icon(Icons.error,color: Colors.red,)
                                ),
                              ),
                              const SizedBox(height: 24,),
                              TextFormField(
                                key: emailFieldKey,
                                controller: inputEmail,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: InputValidations.isValidEmail,
                                onChanged: (String input) async {
                                  await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  border: const OutlineInputBorder(),
                                    suffixIcon: inputEmail.text.isEmpty? null :
                                    emailFieldKey.currentState!.isValid? const Icon(Icons.check_circle_sharp,color: CupertinoColors.systemGreen,) :
                                    const Icon(Icons.error,color: Colors.red,)
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
          ),
          Column(
            children: [
              LoginFooter(
                  disableRightButton: isButtonDisabled,
                  showLeftButton: false,
                  leftButtonLabel: "",
                  rightButtonLabel: "Next",
                  onLeftButtonPressed: (){},
                  onRightButtonPressed: (){
                    //TODO: back-end post request
                    //TODO: Navigate to other pages
                    Navigator.pushNamed(context, CreatePassword.pageRoute);
                  }
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
          )
        ],
      ),
     );
  }
}
