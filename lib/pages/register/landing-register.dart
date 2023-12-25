import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/register/create-account.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../providers/auth.dart';
import '../../util/Toast.dart';
import '../../widgets/auth/auth-app-bar.dart';
import '../home/home.dart';
import '../login/landing-login.dart';


class LandingRegisterPage extends StatefulWidget {
  const LandingRegisterPage({Key? key}) : super(key: key);
  static const pageRoute = '/landing-register';

  @override
  State<LandingRegisterPage> createState() => _LandingRegisterPageState();
}

class _LandingRegisterPageState extends State<LandingRegisterPage> {

  bool _loading = false;
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  void signInWithGoogle() async {
    var authProvider = Auth.getInstance(context);
    var acc = await googleSignIn.signIn();
    print(acc);
    if(acc != null){
      setState(() {
        _loading = true;
      });
      var temp = await acc.authentication;
      String? accessToken = temp.accessToken;
      print("accessToken: $accessToken");
      await authProvider.isValidEmail(
          acc.email,
          success: (res){  // email doesn't exist --> register with google --> need birthDate first
            print("email doesnt exist");
            Navigator.pushReplacementNamed(
              context,
              '/assign-birth-date',
              arguments: {
                "name" : acc.displayName,
                "email" : acc.email,
                "avatarUrl" : acc.photoUrl,
                "id" : acc.id,
                "accessToken": accessToken,
              }
            );
          },
          error: (res) async {  // email already exist --> sign in
            await authProvider.google(
              acc.displayName!,
              acc.email,
              acc.photoUrl,
              acc.id,
              accessToken!,
              null,
              success: (res) {
                Navigator.popUntil(context, (r) => false);
                Navigator.pushNamed(context, Home.pageRoute);
              },
              error: (res) async {
                Toast.showToast(context,"Please log in again.",width: 20);
                await googleSignIn.signOut();
                setState(() {
                  _loading = false;
                });
              },
            );
          }
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return _loading? BlockingLoadingPage() :
    Scaffold(
      appBar: AuthAppBar(context, leadingIcon:
      IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close))
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(35,35,35,100),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 150,),
                  const Text(
                      "See what's happening in the world right now.",
                    style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 150,),
                  ElevatedButton(
                    onPressed: Platform.isAndroid ? signInWithGoogle : () {
                      Toast.showToast(context, "Google sign in is not supported on windows");
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      )
                    ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Image.asset('assets/google-logo-icon.png')
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                            child: Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.blueGrey,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("or"),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, CreateAccount.pageRoute);
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        )
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Create account",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: SizedBox(
          height: 100,
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  text: "By signing up, you agree to our ",
                  style: GoogleFonts.dmSans(
                      textStyle: const TextStyle(color: Colors.blueGrey)),
                  children: [
                    TextSpan(text: "Terms",style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(color: Colors.blue))),
                    TextSpan(text: ", ",style: GoogleFonts.dmSans(
                        textStyle: const TextStyle(color: Colors.blueGrey))),
                    TextSpan(text: "Privacy Policy",style: GoogleFonts.dmSans(
                        textStyle: const TextStyle(color: Colors.blue))),
                    TextSpan(text: ", and ",style: GoogleFonts.dmSans(
                        textStyle: const TextStyle(color: Colors.blueGrey))),
                    TextSpan(text: "Cookie Use",style: GoogleFonts.dmSans(
                        textStyle: const TextStyle(color: Colors.blue))),
                    TextSpan(text: ".",style: GoogleFonts.dmSans(
                        textStyle: const TextStyle(color: Colors.blueGrey))),
                  ]
                )
              ),
              const SizedBox(height: 35,),
              Row(
                children: [
                  const Text(
                    "Have an account already? ",style: TextStyle(color: Colors.blueGrey),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, LandingLoginPage.pageRoute);
                    },
                    child: Text("Log in",
                      style: GoogleFonts.dmSans(
                          textStyle: const TextStyle(color: Colors.blue)
                      ),
                    ),
                  )
                ],
              ),
            ]
          ),
        ),
      ),
    );
  }
}
