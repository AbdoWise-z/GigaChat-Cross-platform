import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/post-class.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/login/login-page.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/pages/register/create-account.dart';
import 'package:gigachat/pages/register/create-password.dart';
import 'package:gigachat/pages/register/landing-register.dart';
import 'package:gigachat/pages/temp.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/feed-component/feed.dart';
import 'package:gigachat/widgets/post.dart';
import 'package:provider/provider.dart';

import 'pages/user-verification/verification-code-page.dart';


void main(){
  WidgetsFlutterBinding.ensureInitialized();

  runApp(GigaChat());
}

class GigaChat extends StatefulWidget {
  String? initialRoute;
  GigaChat({super.key,this.initialRoute});

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
          // print("theme updated");
          return MaterialApp(
            theme: val.getTheme,
            title: "GigaChat",
            initialRoute: widget.initialRoute ?? UsernameLoginPage.pageRoute,
            routes: {
              Tweet.pageRoute : (context) => const FeedWidget(),
              Home.pageRoute : (context) => const Home(),

              LoginPage.pageRoute : (context) => const LoginPage(),
              UsernameLoginPage.pageRoute: (context) => const UsernameLoginPage(),

              ForgetPassword.pageRoute : (context) => ForgetPassword(),
              VerificationCodePage.pageRoute : (context) => const VerificationCodePage(),
              CreateAccount.pageRoute : (context) => const CreateAccount(),
              LoadingPage.pageRoute : (context) => const LoadingPage(),
              CreatePassword.pageRoute : (context) =>  CreatePassword(),
              LandingRegisterPage.pageRoute : (context) => LandingRegisterPage(),
            },
          );
        },
      ),
    );
  }
}

