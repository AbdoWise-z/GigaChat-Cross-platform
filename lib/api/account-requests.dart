
import "dart:math";

import "package:gigachat/base.dart";
import "package:gigachat/util/contact-method.dart";

class User {
  String name;
  String email;
  int followers;
  int following;
  String iconLink;
  String id;
  String? auth;

  bool get isLocalUser {
    return auth != null;
  }

  User({
    this.name = "Abdo",
    this.email = "test@gmail.com",
    this.followers = 0,
    this.following = 1,
    this.iconLink = "https://i.imgur.com/7SbtKvw.png",
    this.id = "Abdo1654",
    this.auth,
  });

}

Future<User?> apiLogin(String userName , String password) async {
  //TODO: do some API request
  await Future.delayed(Duration(milliseconds: 500));
  return User();
}

Future<List<ContactMethod>?> apiGetContactMethods(String email) async {
  //TODO: do some API request
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    ContactMethod(method: ContactMethodType.EMAIL, data: email , title: "Email" , disc: "we will send an email containing a code to \"$email\".")
  ];
}

Future<bool> apiRequestVerificationMethod(ContactMethod method) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return Random().nextBool();
}

Future<bool> apiIsEmailValid(String email) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return Random().nextBool();
}

Future<ContactMethod?> apiRegister(String name , String email , String dob) async {
  ContactMethod method = ContactMethod(method: ContactMethodType.EMAIL, data: email , title: "Email" , disc: "we will send an email containing a code to \"$email\".");
  await Future.delayed(const Duration(milliseconds: 500));
  return method;
}


Future<bool> apiLogout(User u) async {
  //TODO: do some API request
  return true;
}