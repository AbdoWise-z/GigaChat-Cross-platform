import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';

class LoginPage extends StatefulWidget {
  static const String pageRoute = "/login";
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
      return UsernameLoginPage();
  }
}
