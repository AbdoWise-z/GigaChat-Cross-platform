
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/register/confirm-create-account.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
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

  //for controlling focus
  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode dateFocusNode = FocusNode();

  DateTime nonFormattedDate = DateTime.now();

  late final Toast toast;

  @override
  void initState() {
    super.initState();
    toast = Toast(context);
  }

  bool _loading = false;
  void _validateEmail() async {
    //first check if its a valid email or not
    setState(() {
      _loading = true;
    });

    if (!await Auth.getInstance(context).isValidEmail(inputEmail.text, () async {
      setState(() {
        _loading = false;
      });

      final result = await Navigator.pushNamed(
        context,
        ConfirmCreateAccount.pageRoute,
        arguments: {
          "Name" : inputName,
          "Email" : inputEmail,
          "DOB" : inputDOB,
          "nonFormattedDate" : nonFormattedDate,
        },
      );
      if(result == "Name tapped"){
        nameFocus.requestFocus();
      }
      if(result == "Email tapped"){
        emailFocus.requestFocus();
      }
      if(result == "DOB tapped"){
        setState(() {
          dateFocusNode.requestFocus();
        });
      }
    })) {
      toast.showToast('Email is un valid');
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonDisabled = formKey.currentState == null || inputDOB.text.isEmpty || inputName.text.isEmpty
        || inputEmail.text.isEmpty || !formKey.currentState!.validate();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AuthAppBar(context, leadingIcon: null,showDefault: true),
      body: Stack(
        children: [
          Column(
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
                                    focusNode: nameFocus,
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
                                    focusNode: emailFocus,
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
            ],
          ),
          Visibility(
            visible: _loading,
            child: const Positioned.fill(child: BlockingLoadingPage()),
          ),
        ],
      ),
      bottomSheet: SizedBox(
        height: dateFocusNode.hasFocus? 170 : 70,
        child: Column(
          children: [
            AuthFooter(
                disableRightButton: isButtonDisabled,
                showLeftButton: false,
                leftButtonLabel: "",
                rightButtonLabel: "Next",
                onLeftButtonPressed: (){},
                onRightButtonPressed: _validateEmail
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
                        nonFormattedDate = input;
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
