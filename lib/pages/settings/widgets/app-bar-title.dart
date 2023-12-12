import 'package:flutter/material.dart';
import '../../../providers/auth.dart';
import '../../../widgets/text-widgets/main-text.dart';

class SettingsAppBarTitle extends StatelessWidget {
  const SettingsAppBarTitle({Key? key, required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MainText(
          text: text,
          size: 20,
        ),
        MainText(
          text: "@${Auth.getInstance(context).getCurrentUser()!.id}",
          color: Colors.blueGrey,
        )
      ],
    );
  }
}
