import 'package:flutter/material.dart';
import 'forget-password-button.dart';


class LoginFooter extends StatelessWidget {
  final String proceedButtonName;
  void Function()? onPressed;
  bool? showForgetPassword = true;
  String? username;

  LoginFooter({required this.proceedButtonName, super.key, this.onPressed,
    this.username,this.showForgetPassword});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: Color(0xff303030))
          )
      ),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        children: [

          Visibility(child: ForgetPasswordButton(username: username),
              visible: showForgetPassword ?? true
          ),

          const Expanded(child: SizedBox()),


          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.grey[900],
                  backgroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              ),
              onPressed: onPressed ?? (){},
              child: Text(proceedButtonName)
          ),
        ]
        ,
      ),
    );
  }
}
