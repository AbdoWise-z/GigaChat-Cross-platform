import 'package:flutter/material.dart';
import 'package:gigachat/pages/login/widgets/forget-password-button.dart';


class LoginFooter extends StatelessWidget {
  final String proceedButtonName;
  void Function()? onPressed;
  bool? showForgetPassword = true;
  bool? showCancelButton = true;
  bool? showBackButton = true;
  String? username;

  LoginFooter({
    required this.proceedButtonName,
    super.key,
    this.onPressed,
    this.username,
    this.showForgetPassword,
    this.showCancelButton,
    this.showBackButton
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Column(
        children: [
          const Divider(thickness: 0.5, height: 1,),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                Visibility(
                    visible: showForgetPassword ?? true,
                    child: ForgetPasswordButton(username: username
                    )
                ),

                Visibility(
                    visible: showCancelButton ?? false,
                    child: CancelButton()
                ),

                Visibility(
                  visible: showBackButton ?? false,
                  child: BackButtonBottom(),
                ),

                const Expanded(child: SizedBox()),


                ElevatedButton(
                    style: ElevatedButton.styleFrom(

                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    onPressed: onPressed ?? (){},
                    child: Text(proceedButtonName,),
                ),
              ]
              ,
            ),
          ),
        ]
      ),
    );
  }
}
