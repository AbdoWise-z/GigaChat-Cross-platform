import 'package:flutter/material.dart';
import 'package:gigachat/pages/login/landing-login.dart';
import 'package:gigachat/providers/theme-provider.dart';

/// Widgets for buttons in the bottom sheet of authentication pages


ButtonStyle leftButtonStyle()
{
  return OutlinedButton.styleFrom(
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
    return OutlinedButton(
        style: leftButtonStyle(),
        onPressed: () {

        },
        child: Text("Forget password?",
          style: TextStyle(
            color: ThemeProvider.getInstance(context).getTheme.textTheme.labelSmall!.color,
          ),
        ));
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: leftButtonStyle(),
        onPressed: () {
          Navigator.pushNamed(context, LandingLoginPage.pageRoute);
        },
        child: Text("Cancel",
          style: TextStyle(
            color: ThemeProvider.getInstance(context).getTheme.textTheme.labelSmall!.color,
          ),
        ),
    );
  }
}

class BackButtonBottom extends StatelessWidget {
  const BackButtonBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: leftButtonStyle(),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Back"));
  }
}
