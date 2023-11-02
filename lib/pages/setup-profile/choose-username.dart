import 'package:flutter/material.dart';

class ChooseUsername extends StatefulWidget {
  const ChooseUsername({Key? key}) : super(key: key);

  static const pageRoute = '/choose-username';
  @override
  State<ChooseUsername> createState() => _ChooseUsernameState();
}

class _ChooseUsernameState extends State<ChooseUsername> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
