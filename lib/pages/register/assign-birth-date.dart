import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/main-text.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import '../home/home.dart';

class AssignBirthDate extends StatefulWidget {
  static const pageRoute = '/assign-birth-date';
  const AssignBirthDate({Key? key}) : super(key: key);

  @override
  State<AssignBirthDate> createState() => _AssignBirthDateState();
}

class _AssignBirthDateState extends State<AssignBirthDate> {
  bool loading = false;
  bool isButtonDisabled = true;
  TextEditingController inputDOB = TextEditingController();
  FocusNode dateFocusNode = FocusNode();
  DateTime nonFormattedDate = DateTime.now();

  @override
  void dispose() {
    GoogleSignIn().signOut();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    isButtonDisabled = inputDOB.text.isEmpty;
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    return loading? BlockingLoadingPage() :
    Scaffold(
      appBar: AuthAppBar(context, leadingIcon: null, showDefault: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What's your birth date?",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20,),
              const MainText(text: "This won't be public.", color: Colors.grey,),
              const SizedBox(height: 40,),
              TextFormField(
                controller: inputDOB,
                focusNode: dateFocusNode,
                readOnly: true,
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
                onRightButtonPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  if(DateTime.now().difference(nonFormattedDate).inDays < 18 * 365){
                    Toast.showToast(context, "Can't sign up right now");
                  }else{
                    await Auth.getInstance(context).google(
                      args["name"],
                      args["email"],
                      args["avatarUrl"],
                      args["id"],
                      args["accessToken"],
                      "${nonFormattedDate.month}-${nonFormattedDate.day}-${nonFormattedDate.year}",
                      success: (res) {
                        Navigator.popUntil(context, (r) => false);
                        Navigator.pushNamed(context, Home.pageRoute);
                      },
                      error: (res) async {
                        Toast.showToast(context,"Please log in again.",width: 20);
                        await GoogleSignIn().signOut();
                        if(context.mounted) {
                          Navigator.pushReplacementNamed(context, "/landing-register");
                        }
                        setState(() {
                          loading = false;
                        });
                      },
                    );
                  }
                  setState(() {
                    loading = false;
                  });
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
