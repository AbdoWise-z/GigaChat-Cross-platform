

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/main.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';

void main(){
  testWidgets("Testing Button Behaviour", (WidgetTester tester) async {
    // find needed widgets
    final usernameField = find.byKey(const Key(UsernameLoginPage.inputFieldKey));
    final nextButtonField = find.byKey(const Key(UsernameLoginPage.nextButtonKey));

    // executing testing
    await tester.pumpWidget(
        MaterialApp(
            home: GigaChat(initialRoute: UsernameLoginPage.pageRoute)
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

    // Navigating to password page
    await tester.tap(nextButtonField);
    await tester.pumpAndSettle();
    expect(find.text("Enter your password"), findsOneWidget);

    // Checking if the username is there and the login button appeared
    final passwordField = find.byKey(const Key(PasswordLoginPage.passwordFieldKey));
    final loginButton = find.byKey(const Key(PasswordLoginPage.loginButtonKey));
    expect(tester.widget<ElevatedButton>(loginButton).enabled,false);

    // testing some invalid password
    await tester.enterText(passwordField, "this is invalid password");
    await tester.pump();
    expect(tester.widget<ElevatedButton>(loginButton).enabled,false);

    // testing some invalid password
    await tester.enterText(passwordField, "thisIsValidPassword@456");
    await tester.pump();
    expect(tester.widget<ElevatedButton>(loginButton).enabled,true);
  });
}