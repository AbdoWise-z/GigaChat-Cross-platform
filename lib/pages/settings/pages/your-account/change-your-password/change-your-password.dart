import 'package:flutter/material.dart';
import 'package:gigachat/pages/settings/widgets/app-bar-title.dart';
import 'package:gigachat/pages/user-verification/select-verification-method-page.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:gigachat/widgets/text-widgets/main-text.dart';

import '../../../../../providers/auth.dart';
import '../../../../../util/Toast.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  bool isButtonDisabled = true;
  bool loading = false;
  TextEditingController currPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  final formKey = GlobalKey<FormState>();


  void changePassword(String oldPassword, String newPassword) async {
    setState(() {
      loading = true;
    });

    Auth auth = Auth.getInstance(context);
    auth.changeUserPassword(
      oldPassword,
      newPassword,
      success: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);
          loading = false;
          Toast.showToast(context, "Password changed successfully");
          Navigator.pop(context);
        });
      },
      error: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);
          if(res.code == 401){
            Toast.showToast(context, "Your old password you entered in incorrect."
                "Please enter it again.");
          }else{
            Toast.showToast(context, "API Error ..");
          }
          loading = false;
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    isButtonDisabled = formKey.currentState == null || currPassword.text.isEmpty
    || newPassword.text.isEmpty || confirmPassword.text.isEmpty || !formKey.currentState!.validate();
    return Scaffold(
      appBar: AppBar(
        title: const SettingsAppBarTitle(text: "Update password"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Theme(
                data: ThemeProvider.getInstance(context).isDark()? ThemeData.dark() : ThemeData.light(),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MainText(text: "Current password",color: Colors.blueGrey,),
                      TextFormField(
                        obscureText: true,
                        autofocus: true,
                        controller: currPassword,
                        onChanged: (String input) async {
                          await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20,),
                      const MainText(text: "New password",color: Colors.blueGrey,),
                      TextFormField(
                        obscureText: true,
                        controller: newPassword,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          hintText: "At least 8 characters",
                          errorMaxLines: 2,
                        ),
                        onChanged: (String input) async {
                          await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                          setState(() {});
                        },
                        validator: (value){
                          if(value == currPassword.text && value!.isNotEmpty){
                            return "New password cannot be the same as old password";
                          }else if(value!.length < 8 && value.isNotEmpty){
                            return "Your password need to be at least 8 characters. "
                                "Please enter a longer one";
                          }else if(InputValidations.isValidPassword(value) == "weak password!"){
                            return "Your new password is weak";
                          }else{
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 20,),
                      const MainText(text: "Confirm password",color: Colors.blueGrey,),
                      TextFormField(
                        obscureText: true,
                        controller: confirmPassword,
                        decoration: const InputDecoration(
                          hintText: "At least 8 characters"
                        ),
                        onChanged: (String input) async {
                          await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                          setState(() {});
                        },
                        validator: (value){
                          if(value != newPassword.text){
                            return "Passwords doesn't match";
                          }else{
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 20,),
                    ],
                  ),
                )
              ),
              TextButton(
                onPressed: isButtonDisabled? null :() => changePassword(currPassword.text, newPassword.text),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                ),
                child: const Text("Update password",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
              ),
              const SizedBox(height: 10,),
              GestureDetector(
                child: const MainText(text: "Forgot password?",color: Colors.blueGrey,),
                onTap: (){
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) =>
                          VerificationMethodPage(
                              methods: [
                            ContactMethod(
                                method: ContactMethodType.EMAIL,
                                data: Auth.getInstance(context).getCurrentUser()!.email,
                                title: Auth.getInstance(context).getCurrentUser()!.email,
                                disc: ""
                            ),
                          ],
                            isLogged: true,
                        ),
                      )
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
