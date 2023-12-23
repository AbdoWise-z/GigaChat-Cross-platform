import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/firebase_options.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/pages/Search/search.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/login/landing-login.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/pages/profile/profile-image-view.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/pages/register/confirm-create-account.dart';
import 'package:gigachat/pages/register/create-account.dart';
import 'package:gigachat/pages/register/create-password.dart';
import 'package:gigachat/pages/register/landing-register.dart';
import 'package:gigachat/pages/search/search-result.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-information/change-email.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-information/verify-password.dart';
import 'package:gigachat/pages/settings/settings-main-page.dart';
import 'package:gigachat/pages/setup-profile/choose-username.dart';
import 'package:gigachat/pages/setup-profile/setup-profile-picture.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/chat-provider.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/providers/notifications-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/providers/web-socks-provider.dart';
import 'package:gigachat/services/notifications-controller.dart';
import 'package:provider/provider.dart';
import 'widgets/tweet-widget/full-screen-tweet.dart';

GigaChat? application;
final GlobalKey<NavigatorState> appNavigator = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalSettings locals = LocalSettings();
  await locals.init();
  await NotificationsController().init();
  application = GigaChat(locals: locals,);
  runApp(application!);
}

class GigaChat extends StatefulWidget {
  final LocalSettings locals;
  final String? initialRoute;
  const GigaChat({super.key,this.initialRoute , required this.locals});

  @override
  State<GigaChat> createState() => _GigaChatState();
}

class _GigaChatState extends State<GigaChat> {


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WebSocketsProvider>(create: (context) => WebSocketsProvider()),
        ChangeNotifierProvider<Auth>(create: (context) => Auth()),
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
        ChangeNotifierProvider<FeedProvider>(create: (context) => FeedProvider()),
        ChangeNotifierProvider<LocalSettings>(create: (context) => widget.locals),
        ChangeNotifierProvider<NotificationsProvider>(create: (context) => NotificationsProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (context) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_ , theme , __) {
          // print("theme updated");
          return Consumer<Auth>(
            builder: (___ , auth , ____) {
              return MaterialApp(
                key: appNavigator,
                theme: theme.getTheme,
                title: "GigaChat",
                initialRoute: widget.initialRoute ?? LandingLoginPage.pageRoute,
                routes: {
                  Home.pageRoute : (context) => Home(key: homeKey,),
                  ChatPage.pageRoute : (context) => const ChatPage(),

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
                  ViewPostPage.pageRoute : (context) => ViewPostPage(),
                  UserListViewPage.pageRoute : (context) => UserListViewPage(),
                  CreatePostPage.pageRoute : (context) => const CreatePostPage(),
                  SearchPage.pageRoute : (context) => const SearchPage(),
                  SearchResultPage.pageRoute : (context) => const SearchResultPage(),
                  MainSettings.pageRoute : (context) => const MainSettings(),
                  VerifyPasswordPage.pageRoute : (context) => const VerifyPasswordPage(),
                  ChangeEmailPage.pageRoute : (context) => const ChangeEmailPage(),
                  FullScreenImage.pageRoute : (context) => const FullScreenImage()
                },
              );
            }
          );
        },
      ),
    );
  }
}



