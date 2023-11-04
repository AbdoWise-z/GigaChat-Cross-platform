
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TweetActionButton extends StatefulWidget {

  final IconData icon;
  int? count;

  TweetActionButton({super.key, required this.icon, this.count});

  @override
  State<TweetActionButton> createState() => _TweetActionButtonState();
}

MaterialStateProperty<Color> getColor(Color defaultColor,Color onPressedColor)
{
  calcColor(Set<MaterialState> states){
    if(states.contains(MaterialState.pressed)) {
      return onPressedColor;
    } else {
      return defaultColor;
    }
  }
  return MaterialStateProperty.resolveWith(calcColor);
}

class _TweetActionButtonState extends State<TweetActionButton> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: (){},
        style: ButtonStyle(
            foregroundColor: getColor(Colors.grey, Colors.red),
            backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
            padding: MaterialStateProperty.resolveWith((state)=>EdgeInsets.zero)
        ),

        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              const Expanded(child: SizedBox()),
              FaIcon(widget.icon,size: 16),
              const Expanded(child: SizedBox()),
              Visibility(
                visible: widget.count != null,
                  child: Text(widget.count.toString(),style: const TextStyle(fontSize: 13))
              )
            ]
        ),
      ),
    );
  }
}
