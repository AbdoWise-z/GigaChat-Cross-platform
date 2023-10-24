
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/account-requests.dart';



class Auth extends ChangeNotifier{
  static Auth getInstance(BuildContext ctx){
    return Provider.of<Auth>(ctx , listen: false);
  }

  User? _currentUser;

  void login(String username , String password) async {
    _currentUser = await apiLogin(username, password);
    notifyListeners();
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