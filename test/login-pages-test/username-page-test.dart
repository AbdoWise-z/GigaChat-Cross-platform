

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/main.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/providers/local-settings-provider.dart';

void main(){
  testWidgets("Testing Button Behaviour", (WidgetTester tester) async {
    // find needed widgets
      final usernameField = find.byKey(Key(UsernameLoginPage.inputFieldKey));
      final nextButtonField = find.byKey(Key(UsernameLoginPage.nextButtonKey));
    // executing testing

      await tester.pumpWidget(
          MaterialApp(
              home: GigaChat(initialRoute: UsernameLoginPage.pageRoute , locals: LocalSettings())
          )
      );

      // testing wrong username
      await tester.enterText(usernameField, "this is wrong username");
      await tester.pump();
      expect(find.text("this is wrong username"), findsOneWidget);
      expect(tester.widget<ElevatedButton>(nextButtonField).enabled, false);

      // testing correct username
      await tester.enterText(usernameField, "thisIsCorrectUsername123");
      await tester.pump();
      expect(find.text("thisIsCorrectUsername123"), findsOneWidget);
      expect(tester.widget<ElevatedButton>(nextButtonField).enabled, true);



  });
}