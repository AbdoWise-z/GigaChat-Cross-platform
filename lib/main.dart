import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/login/login-page.dart';
import 'package:gigachat/pages/temp.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:provider/provider.dart';


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
      child: Consumer<Auth>(
        builder: (BuildContext context, value, Widget? child) {
          //create main routes here ..
          print("frame updated");
          var auth = Provider.of<Auth>(context);
          return Consumer<ThemeProvider>(
            builder: (_ , val , __) {
              print("theme updated");
              return MaterialApp(
                theme: val.getTheme,
                title: "GigaChat",
                //home: auth.isLoggedIn ? Home() : TempPage(),
                home: LoginPage()
              );
            },
          );
        },
      ),
    );
  }
}

