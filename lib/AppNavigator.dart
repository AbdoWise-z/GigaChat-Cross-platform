import 'package:flutter/material.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/pages/Posts/list-view-page.dart';
import 'package:gigachat/pages/Posts/view-post.dart';
import 'package:gigachat/pages/Search/search.dart';
import 'package:gigachat/pages/create-post/create-post-page.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/home/pages/internal-home-page.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
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
import 'package:gigachat/widgets/tweet-widget/full-screen-tweet.dart';

enum NavigatorDirection{
  HOME,
  CHAT,
}

class AppNavigator {
  static final Map<String , Widget Function(BuildContext)> routes = {
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
  };

  static MaterialPageRoute onBuildHomeRoute(RouteSettings settings){
    if (settings.name == "/"){
      return MaterialPageRoute(
        builder: (c) => InternalHomePage(key: Globals.homeKey,),
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: routes[settings.name!]!,
      settings: settings,
    );
  }

  static MaterialPageRoute onBuildChatRoute(RouteSettings settings){
    if (settings.name == "/"){

      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (_ , __ ) {
              Auth auth = Auth();
              bool isLoggedIn = auth.isLoggedIn;

              return [
                HomeAppBar(
                  pinned: Home.Pages[3].isAppBarPinned(context),
                  userImage: isLoggedIn ? auth.getCurrentUser()!.iconLink : null,
                  title: Home.Pages[3].getTitle(context), /* title (if given a value it will show it instead of the search) */
                  searchBar: Home.Pages[3].getSearchBar(context),
                  actions: Home.Pages[3].getActions(context),
                  controller: Home.Controllers[3],
                  tabs: Home.Pages[3].getTabs(context),
                  disableProfileIcon: true,
                ),
              ];
            },
            body: Home.Controllers[3] != null ? TabBarView(
              controller: Home.Controllers[3],
              children: Home.Pages[3].getTabsWidgets(context)!,
            ) : Home.Pages[3].getPage(context)!,
          ),
        ),
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: routes[settings.name!]!,
      settings: settings,
    );
  }



  static NavigatorState getNavigator(NavigatorDirection src , NavigatorDirection dst){
    switch (src){
      case NavigatorDirection.HOME:
        if (dst == NavigatorDirection.HOME){
          return Globals.homeNavigator.currentState!;
        }else{
          //home going to chat
          if (Globals.isChatSeparated){
            return Globals.chatNavigator.currentState!;
          }else{
            return Globals.homeNavigator.currentState!;
          }
        }
      case NavigatorDirection.CHAT:
        if (Globals.isChatSeparated){
          if (dst == NavigatorDirection.CHAT) {
            return Globals.chatNavigator.currentState!;
          }
          return Globals.homeNavigator.currentState!;
        }else{
          return Globals.homeNavigator.currentState!;
        }
    }
  }
}