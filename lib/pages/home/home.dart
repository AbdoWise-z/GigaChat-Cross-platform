import 'package:flutter/material.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is the home page !"),
            ElevatedButton(onPressed: () {
              Auth.getInstance(context).logout();
            }, child: const Text("Logout")),

            ElevatedButton(onPressed: () {
              ThemeProvider tp = ThemeProvider.getInstance(context);
              if (tp.getThemeName == "dark"){
                tp.setTheme("light");
              }else{
                tp.setTheme("dark");
              }
            }, child: const Text("Change Theme")),
          ],
        ),
      ),
    );
  }
}
