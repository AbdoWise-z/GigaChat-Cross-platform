import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// text widget that applies dmSans font to the text inside it
/// [text] : text inside text widget
/// [size] : font size
/// [color] : font color
/// [bold] : is the text bold or not
class MainText extends StatelessWidget {
  const MainText({Key? key, required this.text, this.size = 15, this.color, this.bold}) : super(key: key);
  final String text;
  final double? size;
  final Color? color;
  final bool? bold;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        color: color ?? (ThemeProvider.getInstance(context).isDark() ? Colors.white : Colors.black),
        fontSize: size,
        fontWeight: (bold != null && bold!)? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
