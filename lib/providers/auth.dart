
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:provider/provider.dart';
import "package:gigachat/api/user-class.dart";

class Auth extends ChangeNotifier{
  static Auth getInstance(BuildContext context){
    return Provider.of<Auth>(context , listen: false);
  }

  //TODO: change back to null
  User? _currentUser = User(
    auth: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1NmI0MjQ2Y2UxODFlMDkxZjQ0ZWQ2OCIsImlhdCI6MTcwMTY5NDg3NCwiZXhwIjoxNzA5NDcwODc0fQ.fzgA0k7GDEptyv2VIjmKZZWNTvzbJLSJMPqssWgUtFI",
    id: "moa_ded_inside",
    name: "Mohamed Adel Ezz Eldin",
    bio: "MoA is ded again",
    iconLink: "https://storage.googleapis.com/gigachat-img.appspot.com/0b9940fd-1532-4e4b-b806-b591f307c40a-download.jpg?GoogleAccessId=firebase-adminsdk-5avio%40gigachat-img.iam.gserviceaccount.com&Expires=253399795200&Signature=DR5oSMgiNZkk%2FerBuAAvI78oN%2BwkkWuxIFkTGVA6O62QLSSnzEvauRkLFJ2Xy%2FmT8DY5zK6tQJYswHvBLdMOfTQa4nI1ROUGmPVlRtivoDvTRFew36JHglhVzfU20V9MTKCcTh5DCUZ40m0lNAdZmfOHSwXBiDD4IkLaKdgxBf106bx6lRZCsMsDU4nbaWzdoEVjycvNi5ExRz4Qwv9B%2Bcekc0I12CxtLXKSS6aGL2zQO9keVR77DyqtypMt81O863SJuKeRYXf7z7k9byLTm%2BXzVaMhEgq%2BdAcx8anmnaEUojLkCsxhcXgOQjU56gBjpDAhIOQ%2FpmJVhisPGz7FEA%3D%3D",
    bannerLink: "https://storage.googleapis.com/gigachat-img.appspot.com/",
  );

  Future<void> login(String username , String password , { void Function(ApiResponse<User>)? success , void Function(ApiResponse<User>)? error}) async {
    var res = await Account.apiLogin(username , password);
    if (res.data != null){
      _currentUser = res.data;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  User? getCurrentUser(){
    return _currentUser;
  }

  logout() async {
    if (_currentUser == null) {
      return;
    }
    bool ok = await Account.apiLogout(_currentUser!);
    if (ok){
      _currentUser = null;
    }
    notifyListeners();
  }

  bool get isLoggedIn {
    return _currentUser != null;
  }

  Future<List<ContactMethod>?> getContactMethods(String email , void Function(List<ContactMethod>) success ) async {
    var methods = await Account.apiGetContactMethods(email);
    if (methods != null){
      success(methods);
    }
    return methods;
  }

  Future<void> requestVerificationMethod(ContactMethod method , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiRequestVerificationMethod(method);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  Future<void> verifyMethod(ContactMethod method , String code , { void Function(ApiResponse<User>)? success , void Function(ApiResponse<User>)? error}) async {
    var res = await Account.apiVerifyMethod(method , code);
    if (res.data != null){
      _currentUser = res.data;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  Future<void> isValidEmail(String email , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiIsEmailValid(email);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> registerUser(String name , String email , String dob , { void Function(ApiResponse<ContactMethod>)? success , void Function(ApiResponse<ContactMethod>)? error}) async {
    var res = await Account.apiRegister(name , email , dob);
    if (res.code == ApiResponse.CODE_SUCCESS){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> createNewUserPassword(String password , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiCreateNewPassword(_currentUser!.auth! , password);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> setUserProfileImage(File img , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Account.apiSetProfileImage(_currentUser!.auth! , img);
    if (res.data != null){
      _currentUser!.iconLink = res.data!;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  Future<void> setUserUsername(String name , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiSetUsername(_currentUser!.auth! , name);
    if (res.data!){
      //update the new username
      _currentUser!.id = name;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> setUserInfo(String name,String bio,String website, String location,DateTime birthDate,
      { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiUpdateUserInfo(_currentUser!.auth! , name,bio,website,location,birthDate);
    if (res.data!){
      _currentUser!.name = name;
      _currentUser!.birthDate = birthDate;
      _currentUser!.website = website;
      _currentUser!.location = location;
      _currentUser!.bio = bio;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  Future<void> setUserBannerImage(File img , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Account.apiSetBannerImage(_currentUser!.auth! , img);
    if (res.data != null){
      _currentUser!.iconLink = res.data!;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

}