import 'package:flutter/material.dart';
import 'package:gigachat/pages/login/forget-password.dart';

class ForgetPasswordButton extends StatelessWidget {
  String? username;

  ForgetPasswordButton({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            side: const BorderSide(width: 1.1, color: Colors.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        onPressed: () {
          // TODO: navigate to the forget password page
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
