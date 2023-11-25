import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/login/landing-login.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/pages/register/confirm-create-account.dart';
import 'package:gigachat/pages/register/create-account.dart';
import 'package:gigachat/pages/register/create-password.dart';
import 'package:gigachat/pages/register/landing-register.dart';
import 'package:gigachat/pages/setup-profile/choose-username.dart';
import 'package:gigachat/pages/setup-profile/setup-profile-picture.dart';
import 'package:gigachat/pages/temp.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/feed-component/feed.dart';
import 'package:gigachat/widgets/post.dart';
import 'package:provider/provider.dart';

import 'pages/user-verification/verification-code-page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalSettings locals = LocalSettings();
  await locals.init();
  runApp(GigaChat(locals: locals,));
}

class GigaChat extends StatefulWidget {
  LocalSettings locals;
  String? initialRoute;
  GigaChat({super.key,this.initialRoute , required this.locals});

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
        ChangeNotifierProvider<LocalSettings>(create: (context) => widget.locals),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_ , theme , __) {
          // print("theme updated");
          return Consumer<Auth>(
            builder: (___ , auth , ____) {
              return MaterialApp(
                theme: theme.getTheme,
                title: "GigaChat",
                initialRoute: widget.initialRoute ?? Tweet.pageRoute,
                routes: {
                  // TODO: for test purposes remove later
                  Tweet.pageRoute : (context) => FeedWidget(showFollowingTweets: true,),

                  Home.pageRoute : (context) => const Home(),

                  LandingLoginPage.pageRoute : (context) => const LandingLoginPage(),
                  UsernameLoginPage.pageRoute: (context) => const UsernameLoginPage(),

                  ForgetPassword.pageRoute : (context) => ForgetPassword(),
                  CreateAccount.pageRoute : (context) => const CreateAccount(),
                  LoadingPage.pageRoute : (context) => const LoadingPage(),
                  CreatePassword.pageRoute : (context) => const CreatePassword(),
                  LandingRegisterPage.pageRoute : (context) => const LandingRegisterPage(),
                  ChooseUsername.pageRoute : (context) => const ChooseUsername(),
                  PickProfilePicture.pageRoute : (context) => const PickProfilePicture(),
                  ConfirmCreateAccount.pageRoute : (context) => const ConfirmCreateAccount(),
                },
              );
            }
          );
        },
      ),
    );
  }
}



