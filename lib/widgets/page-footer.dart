import 'package:flutter/material.dart';
import 'package:gigachat/pages/login/widgets/forget-password-button.dart';


class LoginFooter extends StatelessWidget {
  final String proceedButtonName;
  void Function()? onPressed;
  bool disableNext;
  bool? showForgetPassword = true;
  bool? showCancelButton = true;
  bool? showBackButton = true;
  String? username;
  Key? rightButtonKey;
  Key? leftButtonKey;

  LoginFooter({
    required this.proceedButtonName,
    super.key,
    this.onPressed,
    required this.disableNext,
    this.username,
    this.showForgetPassword,
    this.showCancelButton,
    this.showBackButton,
    this.leftButtonKey,
    this.rightButtonKey,
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
                    child: ForgetPasswordButton(
                        key: leftButtonKey,
                        username: username
                    )
                ),

                Visibility(
                    visible: showCancelButton ?? false,
                    child: CancelButton(
                      key: leftButtonKey,)
                ),

                Visibility(
                  visible: showBackButton ?? false,
                  child: BackButtonBottom(
                    key: leftButtonKey,),
                ),

                const Expanded(child: SizedBox()),


                ElevatedButton(
                  key: rightButtonKey,
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    onPressed: disableNext ? null : onPressed ?? (){},
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
