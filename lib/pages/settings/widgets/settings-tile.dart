import 'package:flutter/material.dart';
import 'package:gigachat/widgets/text-widgets/main-text.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({Key? key,
    required this.icon, required this.onTap,
    required this.mainText, required this.description}) : super(key: key);

  final IconData icon;
  final void Function() onTap;
  final String mainText;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      splashColor: Colors.transparent,
      onTap: onTap,
      minVerticalPadding: 20,
      leading: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Icon(icon,size: 25,),
      ),
      title:  MainText(text: mainText,size: 17,),
      subtitle: MainText(text: description,color: Colors.blueGrey,)
    );
  }
}
