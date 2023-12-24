import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/pages/login/landing-login.dart';
import 'package:gigachat/pages/profile/user-profile.dart';
import 'package:gigachat/pages/register/landing-register.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/local-settings-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:provider/provider.dart';
import "package:gigachat/api/user-class.dart";

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  Widget _createHeader(User? user){
    if (user == null){
      return Column(
        children: [
          const Text(
            "Join GigaChat today",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10,),
          const Text(
            "Create an official GigaChat account to get the full experience.",
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            height: 45,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, LandingRegisterPage.pageRoute);
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.blue)
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
            height: 45,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, LandingLoginPage.pageRoute);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ),
              child: const Text(
                "Log in",
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(user.iconLink),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      border: Border.all(
                        width: 0,
                      )
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: ThemeProvider.getInstance(context).isDark() ? Colors.white : Colors.black,
                  ),
                ),
                child: IconButton(onPressed: () {
                  //TODO : handle account menu
                },
                  icon: const Icon(
                    Icons.more_vert,
                    size: 16,
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5,),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
              "@${user.id}",
              style: ThemeProvider.getInstance(context).getTheme.textTheme.displaySmall
          ),
          const SizedBox(height: 15,),
          Row(
            children: [
              Text(
                "${user.following} ",
              ),
              Text(
                  "Following  ",
                  style: ThemeProvider.getInstance(context).getTheme.textTheme.displaySmall
              ),
              Text(
                "${user.followers} ",
              ),
              Text(
                  "Followers",
                  style: ThemeProvider.getInstance(context).getTheme.textTheme.displaySmall
              ),
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Auth.getInstance(context).isLoggedIn;
    return Consumer<ThemeProvider>(
      builder: (_ , __ , ___) {
        return Drawer(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: _createHeader(Auth.getInstance(context).getCurrentUser()),
                              ),
                              const SizedBox(height: 30,),
                              const Divider(height: 1,thickness: 1,),
                              const SizedBox(height: 30,),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15,0,0,0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      onTap: () async {
                                        //TODO : handle on click
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UserProfile(username: Auth.getInstance(context).getCurrentUser()!.id, isCurrUser: true)
                                          )
                                        );
                                        setState(() {

                                        });
                                      },
                                      horizontalTitleGap: 8,
                                      leading: const Icon(Icons.person_outline),
                                      title: const Text(
                                        "Profile",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),

                                    Visibility(
                                      visible: isLoggedIn,
                                      child: ListTile(
                                        onTap: () {
                                          //TODO : handle on click
                                        },
                                        horizontalTitleGap: 8,
                                        leading: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Image.asset(
                                            ThemeProvider.getInstance(context).isDark() ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png',
                                          ),
                                        ),
                                        title: const Text(
                                          "Premium",
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),

                                    ListTile(
                                      onTap: () {
                                        //TODO : handle on click
                                      },
                                      horizontalTitleGap: 8,
                                      leading: const Icon(Icons.bookmark_border_outlined),
                                      title: const Text(
                                        "Bookmarks",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),

                                    ListTile(
                                      onTap: () {
                                        //TODO : handle on click
                                      },
                                      horizontalTitleGap: 8,
                                      leading: const Icon(Icons.list_alt),
                                      title: const Text(
                                        "Lists",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),

                                    Visibility(
                                      visible: isLoggedIn,
                                      child: ListTile(
                                        onTap: () {
                                          //TODO : handle on click
                                        },
                                        horizontalTitleGap: 8,
                                        leading: const Icon(Icons.mic_none_sharp),
                                        title: const Text(
                                          "Spaces",
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Visibility(
                                      visible: isLoggedIn,
                                      child: ListTile(
                                        onTap: () {
                                          //TODO : handle on click
                                        },
                                        horizontalTitleGap: 8,
                                        leading: const Icon(Icons.attach_money),
                                        title: const Text(
                                          "Monetization",
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(thickness: 1,),
                          const SizedBox(height: 20,),
                          const ExpansionTile(
                            tilePadding: EdgeInsets.fromLTRB(35, 0, 32, 0),
                            title: Text(
                              "Professional Tools",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            children: [

                            ],
                          ),
                          ExpansionTile(
                            tilePadding: const EdgeInsets.fromLTRB(35, 0, 32, 0),
                            title: const Text(
                              "Settings & Support",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            children: [
                              ListTile(
                                onTap: () async {
                                  //TODO : sub-menu action 1
                                  await Navigator.pushNamed(context, '/settings');
                                },
                                horizontalTitleGap: 15,
                                leading: const Padding(
                                  padding: EdgeInsets.fromLTRB(15, 2, 0, 0),
                                  child: Icon(Icons.settings , size: 20,),
                                ),
                                title: const Text(
                                  "Settings and privacy",
                                ),
                              ),
                              ListTile(
                                onTap: () {
                                  //TODO : sub-menu action 2
                                },
                                horizontalTitleGap: 15,
                                leading: const Padding(
                                  padding: EdgeInsets.fromLTRB(15, 2, 0, 0),
                                  child: Icon(Icons.info_outline , size: 20,),
                                ),
                                title: const Text(
                                  "Help Center",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 90,),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  color: ThemeProvider.getInstance(context).isDark()? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15,16,16,16),
                        child: IconButton(onPressed: () {
                          ThemeProvider tp = ThemeProvider.getInstance(context);
                          if (tp.getThemeName == "dark"){
                            tp.setTheme("light");
                          }else{
                            tp.setTheme("dark");
                          }

                        }, icon: Icon(ThemeProvider.getInstance(context).isDark() ? Icons.dark_mode_outlined : Icons.light_mode_outlined)),
                      ),

                      const Expanded(child: SizedBox.shrink()),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: IconButton(onPressed: () async {
                          await Auth.getInstance(context).logout();
                        },
                          icon: const Icon(Icons.logout),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
        );
      }
    );
  }
}
