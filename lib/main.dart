import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/pages/Search/search.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/loading-page.dart';
import 'package:gigachat/pages/login/landing-login.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/pages/register/assign-birth-date.dart';
import 'package:gigachat/pages/register/confirm-create-account.dart';
import 'package:gigachat/pages/register/create-account.dart';
import 'package:gigachat/pages/register/create-password.dart';
import 'package:gigachat/pages/register/landing-register.dart';
import 'package:gigachat/pages/search/search-result.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-information/change-email.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-information/verify-password.dart';
import 'package:gigachat/pages/settings/pages/your-account/account-settings.dart';
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
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'widgets/tweet-widget/full-screen-tweet.dart';

/// Application entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalSettings locals = LocalSettings();
  await locals.init();
  await NotificationsController().init();
  MediaKit.ensureInitialized();

  if (Platform.isWindows) {
    WindowManager windowManager = WindowManager.instance;
    await windowManager.ensureInitialized();
    windowManager.setMinimumSize(const Size(400, 800));
  }

  Globals.application = GigaChat();
  runApp(Globals.application);
}

/// The gigachat Application Wrapper
class GigaChat extends StatefulWidget {
  final String? initialRoute;
  const GigaChat({super.key,this.initialRoute});

  @override
  State<GigaChat> createState() => _GigaChatState();
}

class _GigaChatState extends State<GigaChat> {


  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WebSocketsProvider>(create: (context) => WebSocketsProvider()),
        ChangeNotifierProvider<Auth>(create: (context) => Auth()),
        ChangeNotifierProvider<ThemeProvider>(create: (context) => ThemeProvider()),
        ChangeNotifierProvider<FeedProvider>(create: (context) => FeedProvider()),
        ChangeNotifierProvider<LocalSettings>(create: (context) => LocalSettings()),
        ChangeNotifierProvider<NotificationsProvider>(create: (context) => NotificationsProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (context) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_ , theme , __) {
          // print("theme updated");
          return Consumer<Auth>(
            builder: (___ , auth , ____) {
              return MaterialApp(
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {PointerDeviceKind.mouse , PointerDeviceKind.touch},
                ),
                navigatorKey: Globals.appNavigator,
                theme: theme.getTheme,
                title: "GigaChat",
                initialRoute: widget.initialRoute ?? LandingLoginPage.pageRoute,
                routes: {
                  Home.pageRoute : (context) => Home(),
                  ChatPage.pageRoute : (context) => const ChatPage(),

                  LandingLoginPage.pageRoute : (context) => const LandingLoginPage(),
                  UsernameLoginPage.pageRoute: (context) => const UsernameLoginPage(),

                  CreateAccount.pageRoute : (context) => const CreateAccount(),
                  LoadingPage.pageRoute : (context) => const LoadingPage(),
                  CreatePassword.pageRoute : (context) => const CreatePassword(),
                  LandingRegisterPage.pageRoute : (context) => const LandingRegisterPage(),
                  ChooseUsername.pageRoute : (context) => const ChooseUsername(),
                  PickProfilePicture.pageRoute : (context) => const PickProfilePicture(),
                  ConfirmCreateAccount.pageRoute : (context) => const ConfirmCreateAccount(),
                  ViewPostPage.pageRoute : (context) => ViewPostPage(),
                  UserListViewPage.pageRoute : (context) => const UserListViewPage(),
                  CreatePostPage.pageRoute : (context) => const CreatePostPage(),
                  SearchPage.pageRoute : (context) => const SearchPage(),
                  SearchResultPage.pageRoute : (context) => const SearchResultPage(),
                  MainSettings.pageRoute : (context) => const MainSettings(),
                  VerifyPasswordPage.pageRoute : (context) => const VerifyPasswordPage(),
                  ChangeEmailPage.pageRoute : (context) => const ChangeEmailPage(),
                  FullScreenImage.pageRoute : (context) => const FullScreenImage(),
                  AssignBirthDate.pageRoute : (context) => const AssignBirthDate(),
                  AccountSettings.pageRoute : (context) => const AccountSettings(),
                },
              );
            }
          );
        },
      ),
    );
  }
}



