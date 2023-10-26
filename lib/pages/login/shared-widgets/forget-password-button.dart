import 'package:flutter/material.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/pages/login/login-page.dart';

ButtonStyle leftButtonStyle()
{
  return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      side: const BorderSide(width: 1.1, color: Colors.white),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      )
  );
}

class ForgetPasswordButton extends StatelessWidget {
  String? username;

  ForgetPasswordButton({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: leftButtonStyle(),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ForgetPassword(
                        username: username,
                      )));
        },
        child: const Text("Forget password?"));
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: leftButtonStyle(),
        onPressed: () {
          Navigator.pushNamed(context, LoginPage.pageRoute);
        },
        child: const Text("Cancel"));
  }
}

class BackButtonBottom extends StatelessWidget {
  const BackButtonBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: leftButtonStyle(),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Back"));
  }
}
