

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigachat/main.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';
import 'package:gigachat/pages/login/sub-pages/username-page.dart';
import 'package:gigachat/providers/local-settings-provider.dart';

void main(){
  testWidgets("Testing Button Behaviour", (WidgetTester tester) async {
    // find needed widgets
    final usernameField = find.byKey(const Key(UsernameLoginPage.inputFieldKey));
    final nextButtonField = find.byKey(const Key(UsernameLoginPage.nextButtonKey));
    // executing testing
    await tester.pumpWidget(
        MaterialApp(
            home: GigaChat(initialRoute: UsernameLoginPage.pageRoute , locals: LocalSettings(),)
        )
    );

    // testing wrong username

    String username = "";
    await tester.enterText(usernameField, username);
    await tester.pump();
    expect(find.text(username), findsOneWidget);
    expect(tester.widget<ElevatedButton>(nextButtonField).enabled, false);

    // testing correct username
    username = "StarBoy96";
    await tester.enterText(usernameField, username);
    await tester.pump();
    expect(find.text(username), findsOneWidget);
    expect(tester.widget<ElevatedButton>(nextButtonField).enabled, true);

    // Navigating to password page
    await tester.tap(nextButtonField);
    await tester.pumpAndSettle();
    expect(find.text("Enter your password"), findsOneWidget);


    final passwordField = find.byKey(PasswordLoginPage.passwordFieldKey);
    final loginButton = find.byKey(const Key(PasswordLoginPage.loginButtonKey));


    // Checking if the username is there and the login button appeared
    expect(find.text(username),findsOneWidget); // username is there
    expect(tester.widget<ElevatedButton>(loginButton).enabled,false); // button disabled

    // testing some invalid password
    await tester.enterText(passwordField, "");
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(loginButton).enabled,false);


    // testing a valid password
    await tester.enterText(passwordField, "thisIsValid@456");
    await tester.pumpAndSettle();
    expect(find.text("thisIsValid@456"), findsOneWidget);
    expect(tester.widget<ElevatedButton>(loginButton).enabled,true);
  });
}