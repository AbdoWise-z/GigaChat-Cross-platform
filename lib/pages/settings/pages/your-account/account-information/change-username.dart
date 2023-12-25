import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/text-widgets/main-text.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../services/input-validations.dart';
import '../../../../../util/Toast.dart';
import '../../../../home/home.dart';

class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({Key? key}) : super(key: key);

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {

  final usernameFieldKey = GlobalKey<FormFieldState>();
  late TextEditingController inputUsername;
  bool loading = false;


  void changeUsername(String name) async {
    setState(() {
      loading = true;
    });

    Auth auth = Auth.getInstance(context);
    auth.changeUserUsername(
      name ,
      success: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);
          loading = false;
          Toast.showToast(context, "Username changed successfully");
          Navigator.popUntil(context, ModalRoute.withName(Home.pageRoute));
        });
      },
      error: (res) {
        setState(() {
          print(res.code);
          print(res.responseBody);
          if(res.code == 400){
            Toast.showToast(context, "Username is unavailable.");
          }else{
            Toast.showToast(context, "API Error ..");
          }
          loading = false;
        });
      },
    );
  }

  @override
  void initState() {
    inputUsername = TextEditingController(text: Auth.getInstance(context).getCurrentUser()!.id);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    bool isButtonDisabled = inputUsername.text.isEmpty
        || usernameFieldKey.currentState == null
        || !usernameFieldKey.currentState!.isValid
        || inputUsername.text == Auth.getInstance(context).getCurrentUser()!.id;
    return loading? const BlockingLoadingPage() :
    Scaffold(
      appBar: AppBar(
        title: const MainText(text: "Change username",size: 20,),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(height: 1,color: Colors.blueGrey,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MainText(text: "Current",color: Colors.blueGrey,),
            Theme(
              data: ThemeProvider.getInstance(context).isDark()? ThemeData.dark() : ThemeData.light(),
              child: TextFormField(
                initialValue: Auth.getInstance(context).getCurrentUser()!.id,
                style: GoogleFonts.dmSans(
                  color: Colors.blueGrey,
                  fontSize: 18
                ),
                enabled: false,
              )
            ),
            const SizedBox(height: 30,),
            const MainText(text: "New",color: Colors.grey,),
            Theme(
                data: ThemeProvider.getInstance(context).isDark()? ThemeData.dark() : ThemeData.light(),
                child: TextFormField(
                  key: usernameFieldKey,
                  controller: inputUsername,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: InputValidations.isValidUsername,
                  onChanged: (String input) async {
                    setState(() {
                      isButtonDisabled = true;
                    });
                    await Future.delayed(const Duration(milliseconds: 50));  //wait for validator
                    setState(() {});
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixText: "@",
                    prefixStyle: GoogleFonts.dmSans(),
                    suffixIcon: inputUsername.text.isEmpty ? null :
                    (usernameFieldKey.currentState == null || usernameFieldKey.currentState!.isValid) ?
                    const Icon(Icons.check_circle_sharp, color: CupertinoColors.systemGreen,) :
                    const Icon(Icons.error,color: Colors.red,),
                  ),
                  style: GoogleFonts.dmSans(
                      fontSize: 18
                  ),
                )
            )
          ],
        ),
      ),
      bottomSheet: SizedBox(
        height: 70,
        child: Column(
          children: [
            const Divider(height: 1, color: Colors.blueGrey,),
            Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))
                    ),
                    onPressed: isButtonDisabled? null : () => changeUsername(inputUsername.text),
                    child: const Text("Done"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
