
import "dart:convert";
import "dart:io";
import "dart:math";
import "package:gigachat/api/media-requests.dart";
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

      u.bio         = res["data"]["user"]["bio"]          ?? u.bio;
      u.iconLink    = res["data"]["user"]["profileImage"] ?? u.iconLink;
      u.bannerLink  = res["data"]["user"]["bannerImage"]  ?? u.bannerLink;
      u.location    = res["data"]["user"]["location"]     ?? u.location;
      u.website     = res["data"]["user"]["website"]      ?? u.website;
      u.birthDate   = res["data"]["user"]["birthDate"];
      u.joinedDate  = res["data"]["user"]["joinedAt"];
      u.followers   = res["data"]["user"]["followers_num"];
      u.following   = res["data"]["user"]["followings_num"];

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

    print(k.responseBody);

    if (k.code == ApiResponse.CODE_SUCCESS_CREATED) {
      User u = User();
      var res = jsonDecode(k.responseBody!);

      u.active      = true; //TODO: change this later
      u.auth        = res["token"];
      u.email       = method.data!; //TODO: change this later
      u.id          = res["data"]["suggestedUsername"] ?? "";
      // u.name        = res["data"]["user"]["nickname"];
      //
      // u.bio         = res["data"]["user"]["bio"] ?? u.bio;
      // u.iconLink    = res["data"]["user"]["profileImage"] ?? u.iconLink;
      // u.bannerLink  = res["data"]["user"]["bannerImage"] ?? u.bannerLink;
      // u.location    = res["data"]["user"]["location"] ?? u.location;
      // u.website     = res["data"]["user"]["website"] ?? u.website;
      // u.birthDate   = res["data"]["user"]["birthDate"];
      // u.joinedDate  = res["data"]["user"]["joinedAt"];
      // u.followers   = res["data"]["user"]["followers_num"];
      // u.following   = res["data"]["user"]["followings_num"];

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
    List? links = (await Media.uploadMedia(token, [UploadFile(path: img.path , type: "image" , subtype: "png")])).data;
    if (links == null || links.isEmpty){
      //print("failed to upload profile image");
      return ApiResponse<String>(code: -1, responseBody: "");
    }

    var k = await Api.apiPatch<String>(
      ApiPath.profileImage,
      headers: headers,
      body: json.encode( {
        "profile_image" : links[0],
      }),
    );

    if (k.code == ApiResponse.CODE_SUCCESS_NO_BODY) {
      k.data = links[0];
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