
import "package:gigachat/base.dart";

class User {
  String _name;
  String _email;
  String _id;
  String? _auth;

  bool get isLocalUser {
    return _auth != null;
  }

  String get name {
    return _name;
  }

  String get email {
    return _email;
  }

  String get id {
    return _id;
  }

  User(String name , String email , String id , String auth)
      : _name = name ,
        _email = email ,
        _id = id ,
        _auth = auth;

}

Future<User?> apiLogin(String userName , String password) async {
  //TODO: do some API request

  return User("test", userName, "test_123", "auth key");
}

Future<bool> apiLogout(User u) async {
  //TODO: do some API request

  return true;
}