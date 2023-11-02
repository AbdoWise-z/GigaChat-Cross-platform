import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/login/login-page.dart';
import 'package:gigachat/pages/register/confirm-create-account.dart';
import 'package:gigachat/pages/register/create-account.dart';
import 'package:gigachat/pages/setup-profile/choose-username.dart';
import 'package:gigachat/pages/setup-profile/setup-profile-picture.dart';
import 'package:gigachat/pages/temp.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:provider/provider.dart';

import 'pages/user-verification/verification-code-page.dart';


void main(){
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const GigaChat());
}

class GigaChat extends StatefulWidget {
  const GigaChat({super.key});

  @override
  State<GigaChat> createState() => _GigaChatState();
}

class _GigaChatState extends State<GigaChat> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (context) => Auth()),
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_ , val , __) {
          print("theme updated");
          return MaterialApp(
            theme: val.getTheme,
            title: "GigaChat",
            initialRoute: PickProfilePicture.pageRoute,
            routes: {
              Home.pageRoute : (context) => Home(),
              LoginPage.pageRoute : (context) => LoginPage(),
              ForgetPassword.pageRoute : (context) => ForgetPassword(),
              VerificationCodePage.pageRoute : (context) => VerificationCodePage(),
              CreateAccount.pageRoute : (context) => CreateAccount(),
              LoadingPage.pageRoute : (context) => LoadingPage(),
              ConfirmCreateAccount.pageRoute : (context) => ConfirmCreateAccount(),
              PickProfilePicture.pageRoute : (context) => PickProfilePicture(),
              ChooseUsername.pageRoute : (context) => ChooseUsername(),
            },
          );
        },
      ),
    );
  }
}

