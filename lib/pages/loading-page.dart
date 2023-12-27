import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:loading_indicator/loading_indicator.dart';

/// This is the main loading page of the Gigachat app
class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  static const pageRoute = '/loading';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 65,
              width: 65,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  LoadingIndicator(
                    indicatorType: Indicator.circleStrokeSpin,
                    colors: [ThemeProvider.getInstance(context).isDark() ? Colors.white : Colors.black],
                  ),
                  SizedBox(
                    height: 45,
                    width: 45,
                    child: Image.asset(ThemeProvider.getInstance(context).isDark() ?
                      'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png')
                  )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            const Text("Loading...",
              style: TextStyle(
                  fontSize: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}
