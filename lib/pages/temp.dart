import 'package:flutter/material.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:provider/provider.dart';

class TempPage extends StatefulWidget {
  const TempPage({super.key});

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("T E S T   P A G E"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () {
              Auth.getInstance(context).login("username", "password");
            }, child: const Text("Login"))
          ],
        ),
      ),
    );
  }
}
