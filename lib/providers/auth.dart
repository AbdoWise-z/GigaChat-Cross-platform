
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/api/api.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/providers/web-socks-provider.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/services/events-controller.dart';
import 'package:gigachat/util/contact-method.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import "package:gigachat/api/user-class.dart";

import 'local-settings-provider.dart';

/// this class will be responsible for all user Authorization functionality
/// it will act as a mediator between the API interfaces and Widgets of the
/// Application, it will also implement some of the user other functionalities
/// like following , blocking .. etc.
class Auth extends ChangeNotifier{

  static late FeedProvider feedProvider;
  static Auth getInstance(BuildContext context){
    feedProvider = FeedProvider.getInstance(context);
    return Provider.of<Auth>(context , listen: false);
  }

  Auth._internal();
  static Auth? _instance;
  factory Auth(){
    _instance ??= Auth._internal();
    return _instance!;
  }
  User? _currentUser;

  /// perform a login using [username] and [password]
  /// if the login as successful it will call [success] otherwise it will call [error]
  Future<void> login(String username , String password , { void Function(ApiResponse<User>)? success , void Function(ApiResponse<User>)? error}) async {
    var res = await Account.apiLogin(username , password);
    if (res.data != null){
      _currentUser = res.data;
      WebSocketsProvider prov = WebSocketsProvider();
      print("Auth : ${_currentUser!.auth!}");
      if (await prov.init(_currentUser!.auth! )){
        var settings = LocalSettings.instance;
        settings.setValue<String>(name: "username", val: username);
        settings.setValue<String>(name: "password", val: password);
        settings.setValue<bool>(name: "login", val: true);
        await settings.apply();

        if (success != null) success(res);
      }else{
        _currentUser = null;
        if (error != null) error(res);
      }
    }else{
      if (error != null) error(res);
    }
  }

  /// perform a login using google auth
  /// if the login as successful it will call [success] otherwise it will call [error]
  Future<void> google(
      String name,
      String email,
      String? avatarUrl,
      String id,
      String accessToken,
      String? dob,
      {
        void Function(ApiResponse<User>)? success,
        void Function(ApiResponse<User>)? error,
      }) async {

    var res = await Account.apiGoogle(name , email, avatarUrl, id, accessToken, dob);
    print(res.code);
    if (res.data != null){
      _currentUser = res.data;
      WebSocketsProvider prov = WebSocketsProvider();
      print("Auth : ${_currentUser!.auth!}");
      if ( await prov.init(_currentUser!.auth! )){
        var settings = LocalSettings.instance;
        settings.setValue<String>(name: "username", val: "google boi");
        settings.setValue<String>(name: "password", val: "google boi");
        settings.setValue<bool>(name: "login", val: true);
        await settings.apply();
        if (success != null) success(res);
      }else{
        _currentUser = null;
        if (error != null) error(res);
      }
    }else{
      if (error != null) error(res);
    }
  }

  /// returns the current active user (we use this function alot ... LIKE ALOT)
  /// will be null if the user is not logged in
  /// returns [User] if logged in
  User? getCurrentUser(){
    return _currentUser;
  }

  /// logs the current user out of the app
  /// if the [_currentUser] was null , it will do nothing
  bool _loggingOut = false;
  logout() async {
    if (_currentUser == null) {
      return;
    }

    if (_loggingOut){
      return;
    }
    Globals.appNavigator.currentState!.push(MaterialPageRoute(builder: (_) => BlockingLoadingPage()));

    _loggingOut = true;

    bool ok = await Account.apiLogout(_currentUser!);

    if (ok){
      _currentUser = null;
      var settings = LocalSettings.instance;
      settings.setValue<bool>(name: "login", val: false);
      await settings.apply();
      if (Platform.isAndroid) {
        GoogleSignIn signIn = GoogleSignIn();
        if (await signIn.isSignedIn()) {
          await signIn.signOut();
        }
      }
      if (Globals.appNavigator.currentState != null) {
        Globals.appNavigator.currentState!.pop();
      }
      EventsController.instance.triggerEvent(EventsController.EVENT_LOGOUT, {});
    }else{
      if (Globals.appNavigator.currentState != null) {
        Globals.appNavigator.currentState!.pop();
      }
    }

    _loggingOut = false;
    notifyListeners();
  }

  /// checks if the user is logged in or not
  /// returns true of logged in
  /// false otherwise
  bool get isLoggedIn {
    return _currentUser != null;
  }

  /// gets the [ContactMethod]s for the account liked to [email]
  /// will call [success] if the request was successful
  /// returns a [List] of [ContactMethod] if the request was successful
  /// return null if failed
  Future<List<ContactMethod>?> getContactMethods(String email , void Function(List<ContactMethod>) success ) async {
    var methods = await Account.apiGetContactMethods(email);
    if (methods != null){
      success(methods);
    }
    return methods;
  }

  /// requests a specific [ContactMethod] [method]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> requestVerificationMethod(ContactMethod method , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiRequestVerificationMethod(method);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  /// checks if the password reset [code] is valid or not
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> checkForgotPasswordCode(String code , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiCheckForgotPasswordCode(code);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  /// triggers a [ContactMethod] [method] for forget password
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> forgotPassword(ContactMethod method , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiForgotPassword(method);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  /// verifys a [ContactMethod] [method] with the verification code [code]
  /// [token] is only required if [isVerify] is true
  /// see [Account.apiVerifyMethod(method, code, isVerify, token)] for more details
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> verifyMethod(ContactMethod method , String code ,String? token,bool isVerify, { void Function(ApiResponse<dynamic>)? success , void Function(ApiResponse<dynamic>)? error}) async {
    var res = await Account.apiVerifyMethod(method , code, isVerify,token);
    if (res.data != null){
      if(!isVerify) {
        _currentUser = res.data;
      }else{
        _currentUser!.email = res.data;
      }
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  /// sets a new password [password] using the verification code [code]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> resetPassword(String password ,String code ,{ void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiResetPassword(password , code);
    if (res.data!){
      await logout();
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  /// checks weather [email] is a valid email to register with
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> isValidEmail(String email , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiIsEmailValid(email);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// creates a new user account using [name] , [email] , [dob] as Date of birth
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> registerUser(String name , String email , String dob , { void Function(ApiResponse<ContactMethod>)? success , void Function(ApiResponse<ContactMethod>)? error}) async {
    var res = await Account.apiRegister(name , email , dob);
    if (res.code == ApiResponse.CODE_SUCCESS){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// creates a new password [password] for a user that is being registered
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> createNewUserPassword(String password , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiCreateNewPassword(_currentUser!.auth! , password);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// sets the profile image for the current user with [img]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> setUserProfileImage(File img , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Account.apiSetProfileImage(_currentUser!.auth! , img);
    if (res.data != null){
      _currentUser!.iconLink = res.data!;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  /// sets the username of the current user with [name]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
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

  /// updates the username for the current user with [name]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> changeUserUsername(String name , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiChangeUsername(_currentUser!.auth! , name);
    if (res.data!){
      //update the new username
      _currentUser!.id = name;
      if (success != null) success(res);
      notifyListeners();
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// verifies the password for the current active user for security operations
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> verifyUserPassword(String password , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiVerifyPassword(_currentUser!.auth! , password);
    print(password);
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// changes the email of the current active user with [email]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> changeUserEmail(String email , { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiChangeEmail(_currentUser!.auth! , email);
    if (res.data != null){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// changes the password of the current active user with [newPassword]
  /// requires [oldPassword] for verification
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> changeUserPassword(String oldPassword, String newPassword , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Account.apiChangePassword(_currentUser!.auth! , oldPassword, newPassword);
    if (res.data != null){
      _currentUser!.auth = res.data;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// sets the user [name] , [bio] , [website] , [location] , [birthDate] for the current active user
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
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

  /// changes the banner image for the current active user with [img]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> setUserBannerImage(File img , { void Function(ApiResponse<String>)? success , void Function(ApiResponse<String>)? error}) async {
    var res = await Account.apiSetBannerImage(_currentUser!.auth! , img);
    if (res.data != null){
      _currentUser!.bannerLink = res.data!;
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
  }

  /// makes the current user follow the user with [username]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> follow(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.followUser(_currentUser!.auth! ,username);
    print(res.code);
    if (res.data!){
      _currentUser!.following++;
      notifyListeners();
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// makes the current user unfollow the user with [username]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> unfollow(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.unfollowUser(_currentUser!.auth! ,username);
    print(res.code);
    if (res.data!){
      _currentUser!.following--;
      notifyListeners();
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// makes the current user block the user with [username]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> block(String username, bool isFollowed,bool isFollowingMe, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.blockUser(_currentUser!.auth! ,username);
    if (res.data!){
      refreshFeeds(deleteFeeds: true);
      if(isFollowed) {
        _currentUser!.following--;
      }
      if(isFollowingMe){
        _currentUser!.followers--;
      }
      notifyListeners();
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// makes the current user unblock the user with [username]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> unblock(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.unblockUser(_currentUser!.auth! ,username);
    refreshFeeds();
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// makes the current user mute the user with [username]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> mute(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.muteUser(_currentUser!.auth! ,username);
    refreshFeeds();
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// makes the current user unmute the user with [username]
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> unmute(String username, { void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.unmuteUser(_currentUser!.auth! ,username);
    refreshFeeds();
    if (res.data!){
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }

  /// refreshes the feed to auto update widgets
  /// when a block / unblock , follow / unfollow
  /// happens
  void refreshFeeds({bool deleteFeeds = false}){
    if (deleteFeeds)
      feedProvider.resetAllFeeds();
    feedProvider.updateFeeds();
  }

  /// removes the banner image for the current active user
  /// will call [success] if the request was successful
  /// will call [error] if the request failed
  Future<void> deleteUserBanner({ void Function(ApiResponse<bool>)? success , void Function(ApiResponse<bool>)? error}) async {
    var res = await Account.apiDeleteBannerImage(_currentUser!.auth!);
    if (res.data!){
      _currentUser!.bannerLink = "";
      if (success != null) success(res);
    }else{
      if (error != null) error(res);
    }
    return;
  }




}