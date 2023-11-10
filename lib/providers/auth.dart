
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/base.dart';
import 'package:provider/provider.dart';





class Auth extends ChangeNotifier{
  static Auth getInstance(BuildContext ctx){
    return Provider.of<Auth>(ctx , listen: false);
  }

  User? _currentUser;
  LoginState loginState = LoginState.idle;


  void login(String username , String password) async {
    loginState = LoginState.idle;
    _currentUser = await apiLogin(username, password);
    loginState = _currentUser == null ? LoginState.failure : LoginState.success;
    notifyListeners();
  }

  LoginState getLoginState(){
    return loginState;
  }

  void resetLoginState(){
    loginState = LoginState.idle;
  }

  User? getCurrentUser(){
    return _currentUser;
  }

  logout() async {
    if (_currentUser == null) {
      return;
    }

    bool ok = await apiLogout(_currentUser!);
    if (ok){
      _currentUser = null;
    }
    notifyListeners();
  }

  bool get isLoggedIn {
    return _currentUser != null;
  }
}