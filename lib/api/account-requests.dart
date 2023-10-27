
import "package:gigachat/base.dart";

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
  return User();
}

Future<bool> apiLogout(User u) async {
  //TODO: do some API request

  return true;
}