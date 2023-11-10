
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:provider/provider.dart';


class Auth extends ChangeNotifier{
  static Auth getInstance(BuildContext ctx){
    return Provider.of<Auth>(ctx , listen: false);
  }

  User? _currentUser;

  Future<bool> login(String username , String password , void Function() success ) async {
    _currentUser = await apiLogin(username, password);
    if (_currentUser != null){
      //failed
      success();
      return true;
    }
    return false;
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

  Future<List<ContactMethod>?> getContactMethods(String email , void Function(List<ContactMethod>) success ) async {
    var methods = await apiGetContactMethods(email);
    if (methods != null){
      success(methods);
    }
    return methods;
  }

  Future<bool> requestVerificationMethod(ContactMethod method , void Function() success) async {
    var ok = await apiRequestVerificationMethod(method);
    if (ok){
      success();
      return true;
    }
    return false;
  }

  Future<bool> isValidEmail(String email , void Function() onValid) async {
    var ok = await apiIsEmailValid(email);
    if (ok){
      onValid();
      return true;
    }
    return false;
  }

  Future<bool> registerUser(String name , String email , String dob , void Function(ContactMethod) success) async {
    var k = await apiRegister(name, email, dob);
    if (k != null){
      success(k);
      return true;
    }
    return false;
  }

}