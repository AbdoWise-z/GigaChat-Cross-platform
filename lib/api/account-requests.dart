
import "dart:convert";
import "dart:io";
import "dart:math";
import "package:gigachat/api/user-class.dart";
import "package:gigachat/base.dart";
import "package:gigachat/util/contact-method.dart";

import "api.dart";
class Account {
  static Future<ApiResponse<User>> apiLogin(String userName, String password) async {
    var k = await Api.apiPost<User>(
      ApiPath.login,
      body: json.encode({
        "email": userName,
        "password": password,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );

    print("code: ${k.code} , res: ${k.responseBody}");

    if (k.code == ApiResponse.CODE_SUCCESS_CREATED) {
      User u = User();
      var res = jsonDecode(k.responseBody!);

      u.active      = true; //TODO: change this later
      u.auth        = res["token"];
      u.id          = res["data"]["user"]["username"];
      u.name        = res["data"]["user"]["nickname"];
      u.email       = res["data"]["user"]["email"];
      //u.bio         = res["data"]["user"]["bio"];
      u.iconLink    = res["data"]["user"]["profileImage"] ?? u.iconLink;
      //u.bannerLink  = res["data"]["user"]["banner_image"];
      //u.location    = res["data"]["user"]["location"];
      //u.website     = res["data"]["user"]["website"];
      u.birthDate   = res["data"]["user"]["birthDate"];
      u.joinedDate  = res["data"]["user"]["joinedAt"];
      //u.followers   = res["data"]["user"]["followers_num"];
      //u.following   = res["data"]["user"]["following_num"];

      k.data = u;
    }
    return k;
  }

  static Future<List<ContactMethod>?> apiGetContactMethods(String email) async {
    //TODO: do some API request
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ContactMethod(method: ContactMethodType.EMAIL,
          data: email,
          title: "Email",
          disc: "we will send an email containing a code to \"$email\".")
    ];
  }

  static  Future<ApiResponse<bool>> apiRequestVerificationMethod(ContactMethod method) async {
    var k = await Api.apiPost<bool>(
      ApiPath.resendConfirmEmail,
      body: json.encode({
        "email" : method.data,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }

  static Future<ApiResponse<User>> apiVerifyMethod(ContactMethod method, String code) async {
    var k = await Api.apiPost<User>(
      ApiPath.confirmEmail,
      body: json.encode({
        "email": method.data!,
        "confirmEmailCode": code,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );

    if (k.code == ApiResponse.CODE_SUCCESS_CREATED) {
      User u = User();
      var res = jsonDecode(k.responseBody!);

      u.active      = true; //TODO: change this later
      u.auth        = res["token"];
      u.id          = res["data"]["user"]["username"];
      u.name        = res["data"]["user"]["nickname"];
      u.email       = res["data"]["user"]["email"];
      //u.bio         = res["data"]["user"]["bio"];
      //u.iconLink    = res["data"]["user"]["profile_image"];
      //u.bannerLink  = res["data"]["user"]["banner_image"];
      //u.location    = res["data"]["user"]["location"];
      //u.website     = res["data"]["user"]["website"];
      u.birthDate   = res["data"]["user"]["birthDate"];
      u.joinedDate  = res["data"]["user"]["joinedAt"];
      //u.followers   = res["data"]["user"]["followers_num"];
      //u.following   = res["data"]["user"]["following_num"];

      k.data = u;
    }
    return k;
  }


  static Future<ApiResponse<bool>> apiIsEmailValid(String email) async {
    var k = await Api.apiPost<bool>(
      ApiPath.checkExistedEmail,
      body: json.encode({
        "email": email,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );
    k.data = k.code == ApiResponse.CODE_NOT_FOUND;
    return k;
  }

  static Future<ApiResponse<ContactMethod>> apiRegister(String name, String email, String dob) async {
    ContactMethod method = ContactMethod(method: ContactMethodType.EMAIL,
        data: email,
        title: "Email",
        disc: "we will send an email containing a code to \"$email\".");

    var k = await Api.apiPost<ContactMethod>(
      ApiPath.signUp,
      body: json.encode({
        "email": email,
        "nickname" : name,
        "birthDate" : dob
      }),
      headers: Api.JSON_TYPE_HEADER,
    );
    k.data = method;
    return k;
  }

  static Future<ApiResponse<bool>> apiCreateNewPassword(String token, String password) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<bool>(
      ApiPath.assignPassword,
      body: json.encode({
        "password": password,
      }),
      headers: headers,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }

  static Future<ApiResponse<String>> apiSetProfileImage(String token, File img) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<String>(
      ApiPath.profileImage,
      headers: headers,
      files: {
        "profile_image" : img.path
      }
    );
    if (k.code == ApiResponse.CODE_SUCCESS) {
      var res = jsonDecode(k.responseBody!);
      k.data = res["image_profile_url"];
    }
    return k;
  }


  static Future<ApiResponse<bool>> apiSetUsername(String token, String name) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<bool>(
      ApiPath.assignUsername,
      body: json.encode({
        "username": name,
      }),
      headers: headers,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }


  static Future<bool> apiLogout(User u) async {
    //TODO: do some API request
    return true;
  }

}