import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/pages/login/login-page.dart';
import 'package:gigachat/pages/register/create-account.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/theme-provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email'],
);
Future signInWithGoogle() async{

  GoogleSignInAccount? acc;
  try{
    acc = await googleSignIn.signIn();
  }catch(e){
    print(e);
  }
  return acc;
}
Future signOutWithGoogle() async{
  googleSignIn.disconnect();
}

class LandingRegisterPage extends StatelessWidget {
  const LandingRegisterPage({Key? key}) : super(key: key);
  static const pageRoute = '/landing-register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        elevation: 0,
        centerTitle: true,
        leading: const Icon(Icons.close),
        title: SizedBox(
          height: 40,
          width: 40,
          child: Image.asset(
            ThemeProvider.getInstance(context).isDark() ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png',
          ),
        ),
      ),
      body: Padding(
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
                  onPressed: () async {
                    var acc = await signInWithGoogle();
                    print(acc);
                    await signOutWithGoogle();
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
                        width: 35,
                        height: 35,
                        child: Image.asset('assets/google-logo-icon.png')
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
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
                      Navigator.pushNamed(context, LoginPage.pageRoute);
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
