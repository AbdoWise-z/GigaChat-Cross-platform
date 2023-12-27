
import "dart:convert";
import "dart:io";
import "package:gigachat/api/media-requests.dart";
import "package:gigachat/api/user-class.dart";
import "package:gigachat/providers/web-socks-provider.dart";
import "package:gigachat/services/events-controller.dart";
import "package:gigachat/services/notifications-controller.dart";
import "package:gigachat/util/contact-method.dart";
import "api.dart";

/// this class is responsible for handling all the account related requests
/// login , logout , getting the contact methods , etc ..
class Account {

  /// performs a login using [userName] and [password] and returns the logged in
  /// user in case login was successful or null if failed
  static Future<ApiResponse<User>> apiLogin(String userName, String password) async {
    await NotificationsController.getInstance().login();

    var k = await Api.apiPost<User>(
      ApiPath.login,
      body: json.encode({
        "query": userName,
        "password": password,
        "push_token": NotificationsController.FirebaseToken,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );

    if (k.code == ApiResponse.CODE_SUCCESS) {
      User u = User();
      var res = jsonDecode(k.responseBody!);
      u.active      = true;
      u.auth        = res["token"];
      u.id          = res["data"]["user"]["username"];
      u.name        = res["data"]["user"]["nickname"];
      u.email       = res["data"]["user"]["email"];
      u.bio         = res["data"]["user"]["bio"] ?? "";
      u.iconLink    = res["data"]["user"]["profileImage"] ?? u.iconLink;
      u.bannerLink  = res["data"]["user"]["bannerImage"] ?? "";
      //u.location    = res["data"]["user"]["location"];
      //u.website     = res["data"]["user"]["website"];
      u.birthDate   = DateTime.parse(res["data"]["user"]["birthDate"]);
      u.joinedDate  = DateTime.parse(res["data"]["user"]["joinedAt"]);
      u.followers   = res["data"]["user"]["followers_num"];
      u.following   = res["data"]["user"]["followings_num"];
      u.numOfPosts  = res["data"]["user"]["numOfPosts"];
      u.numOfLikes  = res["data"]["user"]["numOfLikes"];
      u.mongoID     = res["data"]["user"]["_id"];
      k.data = u;

    }
    return k;
  }

  /// no actual backend implementation for this one
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

  /// requests a verification method [method] from the server
  /// returns true if the request we successful or false if it failed
  static Future<ApiResponse<bool>> apiRequestVerificationMethod(ContactMethod method) async {
    var k = await Api.apiPost<bool>(
      ApiPath.resendConfirmEmail,
      body: json.encode({
        "email" : method.data,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    print(k.code);
    return k;
  }

  /// sends a password reset code request to the server using the [method] as
  /// a contact method , returns true if success and false if failed
  static  Future<ApiResponse<bool>> apiForgotPassword(ContactMethod method) async {
    var k = await Api.apiPost<bool>(
      ApiPath.forgotPassword,
      body: json.encode({
        "query" : method.data,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    print(k.code);
    return k;
  }

  /// validates the forget code entered by the user
  /// returns true if success and false if failed or wrong code
  static  Future<ApiResponse<bool>> apiCheckForgotPasswordCode(String code) async {
    var k = await Api.apiPost<bool>(
      ApiPath.checkForgotPasswordCode,
      body: json.encode({
        "passwordResetToken" : code,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );
    print(k.code);
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }

  /// verify a [ContactMethod] [method] using a code ,
  /// depending on [isVerify] if its true then the user is trying to
  /// verify while he's logged in , otherwise he's logged out or
  /// creating an account
  static Future<ApiResponse<dynamic>> apiVerifyMethod(ContactMethod method, String code, bool isVerify, String? token) async {
    Map<String,String> headers =  isVerify? Api.getTokenWithJsonHeader("Bearer $token") : Api.JSON_TYPE_HEADER;
    var k = await Api.apiPost<dynamic>(
      isVerify? ApiPath.verifyEmail: ApiPath.confirmEmail,
      body: json.encode({
        "email": method.data!,
        isVerify? "verifyEmailCode" : "confirmEmailCode": code,
      }),
      headers: headers,
    );

    if (k.code == ApiResponse.CODE_SUCCESS_CREATED && !isVerify) {
      User u = User();
      var res = jsonDecode(k.responseBody!);
      print(res);

      u.active      = true;
      u.auth        = res["token"];
      u.id          = res["data"]["suggestedUsername"];
      //u.name        = res["data"]["user"]["nickname"];
      u.email       = method.data!;
      //u.bio         = res["data"]["user"]["bio"];
      //u.iconLink    = res["data"]["user"]["profile_image"];
      //u.bannerLink  = res["data"]["user"]["banner_image"];
      //u.location    = res["data"]["user"]["location"];
      //u.website     = res["data"]["user"]["website"];
      //u.birthDate   = res["data"]["user"]["birthDate"];
      //u.joinedDate  = res["data"]["user"]["joinedAt"];
      //u.followers   = res["data"]["user"]["followers_num"];
      //u.following   = res["data"]["user"]["following_num"];

      k.data = u;
    }else if(k.code == ApiResponse.CODE_SUCCESS && isVerify){
      k.data = method.data;
    }
    return k;
  }

  /// resets the password of this user with a new password [password] using [code]
  /// returns true if success and false if failed or the [code] is invalid
  static Future<ApiResponse<bool>> apiResetPassword(String password, String code) async {
    var k = await Api.apiPatch<bool>(
      ApiPath.resetPassword,
      body: json.encode({
        "password": password,
        "passwordResetToken" : code,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );
    print(k.code);
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }

  /// checks weather or not we can create an account using this [email]
  /// returns true if success and false if failed or the email is already registered
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

  /// creates a new user account using with [name] and [email]
  /// with data of birth equal to [dob]
  /// returns a [ContactMethod] to verify to confirm creating this account
  /// or null if the request fails
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

  /// assigns a new password a newly created user with token [token]
  /// and sets its password to [password]
  /// returns true if success and false if failed
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


  /// sets a user profile image using user token [token] to the image provided in [img]
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
    print("avatar: ${k.code}");
    if (k.code == ApiResponse.CODE_SUCCESS_NO_BODY) {
      k.data = links[0];
    }
    return k;
  }

  /// sets a user username using user token [token] to the username provided in [name]
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

  /// logs the current active user out
  static Future<bool> apiLogout(User u) async {
    await NotificationsController.getInstance().logout();
    WebSocketsProvider.instance.destroy();
    return true;
  }

  /// retrieves the current active user profile details using its token [token]
  /// returns [ApiResponse] contains null data if failed otherwise it will contain
  /// the user details
  static Future<ApiResponse<User>> apiCurrUserProfile(String token) async{
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiGet<User>(
        ApiPath.currUserProfile,
      headers: headers,
    );
    User u = User();
    if(k.code == ApiResponse.CODE_SUCCESS){
      var res = json.decode(k.responseBody!);
      print(token);
      print(res);
      u.id          = res["user"]["username"];
      u.name        = res["user"]["nickname"];
      u.bio         = res["user"]["bio"] ?? "";
      u.iconLink    = res["user"]["profile_image"];
      u.bannerLink  = res["user"]["banner_image"] ?? "";
      //u.location  = res["user"]["location"];  //const cuz its not a feature
      //u.website   = res["user"]["website"];   //const cuz its not a feature
      u.birthDate   = DateTime.parse(res["user"]["birth_date"]);
      u.joinedDate  = DateTime.parse(res["user"]["joined_date"]);
      u.numOfPosts  = res["user"]["num_of_posts"];
      u.numOfLikes  = res["user"]["num_of_likes"];
      u.mongoID     = res["user"]["_id"];
    }else{
      u.birthDate   = DateTime.now();
      u.joinedDate  = DateTime.now();
    }
    k.data = u;
    return k;
  }

  /// retrieves a normal user profile using his [username]
  /// returns [ApiResponse] contains null data if failed otherwise it will contain
  /// the user details
  static Future<ApiResponse<User>> apiUserProfile(String token,String username) async{
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiGet<User>(
      ApiPath.userProfile.format([username]),
      headers: headers,
    );
    User u = User();
    if(k.code == ApiResponse.CODE_SUCCESS){
      var res = json.decode(k.responseBody!);
      print(res);
      u.id                    = res["user"]["username"];
      u.name                  = res["user"]["nickname"];
      u.bio                   = res["user"]["bio"] ?? "";
      u.iconLink              = res["user"]["profile_image"];
      u.bannerLink            = res["user"]["banner_image"] ?? "";
      //u.location            = res["user"]["location"];  //const cuz its not a feature
      //u.website             = res["user"]["website"];   //const cuz its not a feature
      u.birthDate             = DateTime.parse(res["user"]["birth_date"]);
      u.joinedDate            = DateTime.parse(res["user"]["joined_date"]);
      u.followers             = res["user"]["followers_num"];
      u.following             = res["user"]["followings_num"];
      u.isFollowed            = res["user"]["is_wanted_user_followed"];
      u.isWantedUserMuted     = res["user"]["is_wanted_user_muted"];
      u.isWantedUserBlocked   = res["user"]["is_wanted_user_blocked"];
      u.isCurrUser            = res["user"]["is_curr_user"];
      u.isCurrUserBlocked     = res["user"]["is_curr_user_blocked"];
      u.numOfPosts            = res["user"]["num_of_posts"];
      u.numOfLikes            = res["user"]["num_of_likes"];
      u.mongoID               = res["user"]["_id"];
      u.isFollowingMe         = res["user"]["isFollowingMe"];
    }else{
      u.birthDate   = DateTime.now();
      u.joinedDate  = DateTime.now();
      u.mongoID = "NOT FOUND";
    }
    k.data = u;
    return k;
  }

  /// retrieves a normal user profile using his [id] the database mongo ID
  /// returns [ApiResponse] contains null data if failed otherwise it will contain
  /// the user details
  static Future<ApiResponse<User>> apiUserProfileWithID(String token,String id) async{
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiGet<User>(
      ApiPath.userProfileWithID.format([id]),
      headers: headers,
    );
    User u = User();
    if(k.code == ApiResponse.CODE_SUCCESS){
      var res = json.decode(k.responseBody!);
      print(res);
      u.id                    = res["user"]["username"];
      u.name                  = res["user"]["nickname"];
      u.bio                   = res["user"]["bio"] ?? "";
      u.iconLink              = res["user"]["profile_image"];
      u.bannerLink            = res["user"]["banner_image"] ?? "";
      //u.location            = res["user"]["location"];  //const cuz its not a feature
      //u.website             = res["user"]["website"];   //const cuz its not a feature
      u.birthDate             = DateTime.parse(res["user"]["birth_date"]);
      u.joinedDate            = DateTime.parse(res["user"]["joined_date"]);
      u.followers             = res["user"]["followers_num"];
      u.following             = res["user"]["followings_num"];
      u.isFollowed            = res["user"]["is_wanted_user_followed"];
      u.isWantedUserMuted     = res["user"]["is_wanted_user_muted"];
      u.isWantedUserBlocked   = res["user"]["is_wanted_user_blocked"];
      u.isCurrUser            = res["user"]["is_curr_user"];
      u.isCurrUserBlocked     = res["user"]["is_curr_user_blocked"];
      u.numOfPosts            = res["user"]["num_of_posts"];
      u.numOfLikes            = res["user"]["num_of_likes"];
      u.mongoID               = res["user"]["_id"];
    }else{
      u.birthDate   = DateTime.now();
      u.joinedDate  = DateTime.now();

    }
    k.data = u;
    return k;
  }

  /// updates the current active user info using the user [token]
  /// setting the user name to [name]
  /// and the user boi to [boi]
  /// and the user website to [website]
  /// abd the user location to [location]
  /// and his birth date to [birthDate]
  /// will return true if success and false if failed
  static Future<ApiResponse<bool>> apiUpdateUserInfo(
      String token,
      String name,
      String bio,
      String website,
      String location,
      DateTime birthDate
      ) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<bool>(
      ApiPath.updateUserInfo,
      body: json.encode(
        {
          "nickname" : name,
          "bio" : bio,
          "location" : location,
          "website" : website,
          "birth_date" : birthDate.toString(),
        }
      ),
      headers: headers,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS_NO_BODY;
    print(k.code);
    return k;
  }

  /// set the user associated with [token] profile image's to [img]
  /// return the link of the new profile image if success
  /// and null if failed
  static Future<ApiResponse<String>> apiSetBannerImage(String token, File img) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    List? links = (await Media.uploadMedia(token, [UploadFile(path: img.path , type: "image" , subtype: "png")])).data;
    if (links == null || links.isEmpty){
      //print("failed to upload profile image");
      return ApiResponse<String>(code: -1, responseBody: "");
    }

    var k = await Api.apiPatch<String>(
      ApiPath.banner,
      headers: headers,
      body: json.encode( {
        "profile_banner" : links[0],
      }),
    );
    print("banner: ${k.code}");
    if (k.code == ApiResponse.CODE_SUCCESS_NO_BODY) {
      k.data = links[0];
    }
    return k;
  }

  /// set the user associated with [token] username's to [username]
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> apiChangeUsername(String token, String username) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<bool>(
      ApiPath.updateUsername,
      body: json.encode({
        "newUsername": username,
      }),
      headers: headers,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }

  /// verify the user associated with [token] password
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> apiVerifyPassword(String token, String password) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPost<bool>(
      ApiPath.verifyPassword,
      body: json.encode({
        "password": password,
      }),
      headers: headers,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }

  /// set the user associated with [token] email's to [email]
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> apiChangeEmail(String token, String email) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPost<bool>(
      ApiPath.updateEmail,
      body: json.encode({
        "email": email,
      }),
      headers: headers,
    );
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }

  /// set the user associated with [token] password to a new password [newPassword]
  /// [oldPassword] is used for verification
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<String>> apiChangePassword(String token, String oldPassword, String newPassword) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<String>(
      ApiPath.updatePassword,
      body: json.encode({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      }),
      headers: headers,
    );
    if(k.code == ApiResponse.CODE_SUCCESS){
      var res = json.decode(k.responseBody!);
      k.data = res["token"];
    }
    return k;
  }

  /// makes the user associated with [token] follow the user associated [username]
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> followUser(String token, String username) async
  {
      ApiPath endPoint = (ApiPath.followUser).format([username]);
      Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
      var k = await Api.apiPost<bool>(endPoint,headers: headers);
      print(k.code);
      k.data =  k.code == ApiResponse.CODE_SUCCESS_NO_BODY;
      if (k.data!){
        EventsController.instance.triggerEvent(EventsController.EVENT_USER_FOLLOW, {"username" : username});
      }
      return k;
  }

  /// makes the user associated with [token] unfollow the user associated [username]
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> unfollowUser(String token, String username) async
  {
      ApiPath endPoint = (ApiPath.unfollowUser).format([username]);
      Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
      print(token);
      var k = await Api.apiPost<bool>(endPoint,headers: headers);
      k.data =  k.code == ApiResponse.CODE_SUCCESS_NO_BODY;
      if (k.data!){
        EventsController.instance.triggerEvent(EventsController.EVENT_USER_UNFOLLOW, {"username" : username});
      }
      return k;
  }

  /// makes the user associated with [token] mute the user associated [username]
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> muteUser(String token, String username) async
  {
    ApiPath endPoint = (ApiPath.muteUser).format([username]);
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<bool>(endPoint,headers: headers);
    print(k.code);
    k.data =  k.code == ApiResponse.CODE_SUCCESS_NO_BODY;
    if (k.data!){
      EventsController.instance.triggerEvent(EventsController.EVENT_USER_MUTE, {"username" : username});
    }
    return k;
  }

  /// makes the user associated with [token] unmute the user associated [username]
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> unmuteUser(String token, String username) async
  {
    ApiPath endPoint = (ApiPath.unmuteUser).format([username]);
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<bool>(endPoint,headers: headers);
    print(k.code);
    k.data =  k.code == ApiResponse.CODE_SUCCESS_NO_BODY;
    if (k.data!){
      EventsController.instance.triggerEvent(EventsController.EVENT_USER_UNMUTE, {"username" : username});
    }
    return k;
  }

  /// makes the user associated with [token] block the user associated [username]
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> blockUser(String token, String username) async
  {
    ApiPath endPoint = (ApiPath.blockUser).format([username]);
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<bool>(endPoint,headers: headers);
    print(k.code);
    k.data =  k.code == ApiResponse.CODE_SUCCESS_NO_BODY;
    if (k.data!){
      EventsController.instance.triggerEvent(EventsController.EVENT_USER_BLOCK, {"username" : username});
    }
    return k;
  }

  /// makes the user associated with [token] unblock the user associated [username]
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> unblockUser(String token, String username) async
  {
    ApiPath endPoint = (ApiPath.unblockUser).format([username]);
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiPatch<bool>(endPoint,headers: headers);
    print(k.code);
    k.data = k.code == ApiResponse.CODE_SUCCESS_NO_BODY;
    if (k.data!){
      EventsController.instance.triggerEvent(EventsController.EVENT_USER_UNBLOCK, {"username" : username});
    }
    return k;
  }

  /// remove the user associated with [token] banner's image
  /// return true if success
  /// and false if failed
  static Future<ApiResponse<bool>> apiDeleteBannerImage(String token) async {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiDelete<bool>(
      ApiPath.banner,
      headers: headers,
    );
    print("delete banner: ${k.code}");
    k.data = k.code == ApiResponse.CODE_SUCCESS;
    return k;
  }

  /// returns a list of the user associated with [token] followers
  /// return list if success
  /// and null if failed
  static Future<ApiResponse<List<User>>> getUserFollowers(String token, String username, int page , int count) async
  {
    ApiPath endPoint = (ApiPath.userFollowers).format([username]);
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiGet<List<User>>(
      endPoint,
      headers: headers,
      params: {
        "page" : page.toString(),
        "count" : count.toString(),
      }
    );
    print(k.code);
    if(k.code == ApiResponse.CODE_SUCCESS && k.responseBody != null){
      if (k.responseBody!.isEmpty){
        k.data = [];
        return k;
      }
      var res = json.decode(k.responseBody!);
      List temp = res["users"];
      List<User> users = temp.map((e) => User(
        id: e["username"],
        name: e["nickname"],
        isFollowed: e["isFollowed"],
        followers: e["followers_num"],
        following: e["followings_num"],
        iconLink: e["profile_image"],
        bio: e["bio"] ?? "",
      )).toList();

      k.data = users;
    }

    return k;
  }

  /// returns a list of the user associated with [token] following users
  /// return list if success
  /// and null if failed
  static Future<ApiResponse<List<User>>> getUserFollowings(String token, String username, int page , int count) async
  {
    ApiPath endPoint = (ApiPath.userFollowings).format([username]);
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiGet<List<User>>(
        endPoint,
        headers: headers,
        params: {
          "page" : page.toString(),
          "count" : count.toString(),
        }
    );
    print(k.code);
    if(k.code == ApiResponse.CODE_SUCCESS){
      var res = json.decode(k.responseBody!);
      List temp = res["users"];
      List<User> users = temp.map((e) => User(
        id: e["username"],
        name: e["nickname"],
        isFollowed: e["isFollowed"],
        followers: e["followers_num"],
        following: e["followings_num"],
        iconLink: e["profile_image"],
        bio: e["bio"] ?? "",
      )).toList();

      k.data = users;
    }
    return k;
  }

  /// returns a list of the user associated with [token] blocked users
  /// return list if success
  /// and null if failed
  static Future<ApiResponse<List<User>>> getUserBlockedList(String token, int page , int count) async
  {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiGet<List<User>>(
        ApiPath.userBlockList,
        headers: headers,
        params: {
          "page" : page.toString(),
          "count" : count.toString(),
        }
    );
    print(k.code);
    if(k.code == ApiResponse.CODE_SUCCESS){
      var res = json.decode(k.responseBody!);
      List temp = res["data"];
      List<User> users = temp.map((e) => User(
        id: e["username"],
        name: e["nickname"],
        iconLink: e["profile_image"],
        bio: e["bio"] ?? "",
        isWantedUserMuted: e["isMuted"],
        isWantedUserBlocked: true,
      )).toList();

      k.data = users;
    }
    return k;
  }

  /// returns a list of the user associated with [token] muted users
  /// return list if success
  /// and null if failed
  static Future<ApiResponse<List<User>>> getUserMutedList(String token, int page , int count) async
  {
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    var k = await Api.apiGet<List<User>>(
        ApiPath.userMutedList,
        headers: headers,
        params: {
          "page" : page.toString(),
          "count" : count.toString(),
        }
    );
    print(k.code);
    if(k.code == ApiResponse.CODE_SUCCESS){
      var res = json.decode(k.responseBody!);
      List temp = res["data"];
      List<User> users = temp.map((e) => User(
        id: e["username"],
        name: e["nickname"],
        isFollowed: e["isFollowed"],
        iconLink: e["profile_image"],
        bio: e["bio"] ?? "",
        isWantedUserBlocked: e["isBlocked"],
        isWantedUserMuted: true,
      )).toList();

      k.data = users;
    }
    return k;
  }

  /// login using google auth
  /// if the account exists, it will just login
  /// if it doesn't exist it will create a new account using
  /// [name] as the person name
  /// [avatarUrl] as the user image
  /// [email] as the user email
  /// [dob] as the date of birth
  /// return the user if login was successful
  /// otherwise returns null
  static Future<ApiResponse<User>> apiGoogle(String name, String email, String? avatarUrl, String id, String accessToken, String? dob) async {
    await NotificationsController.getInstance().login();

    var k = await Api.apiPost<User>(
      ApiPath.google,
      body: json.encode({
        "access_token": accessToken,
        "email": email,
        "name" : name,
        "id": id,
        "profileImage" : avatarUrl,
        "birthDate" : dob,
        "push_token" : NotificationsController.FirebaseToken,
      }),
      headers: Api.JSON_TYPE_HEADER,
    );

    if (k.code == ApiResponse.CODE_SUCCESS_CREATED) {
      User u = User();
      var res = jsonDecode(k.responseBody!);
      print(res);
      u.active      = true;
      u.auth        = res["token"];
      u.id          = res["data"]["user"]["username"];
      u.name        = res["data"]["user"]["nickname"];
      u.email       = res["data"]["user"]["email"];
      u.bio         = res["data"]["user"]["bio"] ?? "";
      u.iconLink    = res["data"]["user"]["profileImage"] ?? u.iconLink;
      u.bannerLink  = res["data"]["user"]["bannerImage"] ?? "";
      //u.location    = res["data"]["user"]["location"];
      //u.website     = res["data"]["user"]["website"];
      u.birthDate   = DateTime.parse(res["data"]["user"]["birthDate"]);
      u.joinedDate  = DateTime.parse(res["data"]["user"]["joinedAt"]);
      u.followers   = res["data"]["user"]["followers_num"] ?? 0;
      u.following   = res["data"]["user"]["followings_num"] ?? 0;
      u.numOfPosts  = res["data"]["user"]["numOfPosts"] ?? 0;
      u.numOfLikes  = res["data"]["user"]["numOfLikes"] ?? 0;
      u.mongoID     = res["data"]["user"]["_id"];
      k.data = u;
    }
    return k;
  }
}