/// code is this file will provide all the utility needed to
/// communicate with the App API through web requests

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:gigachat/base.dart';
import 'package:sprintf/sprintf.dart';

/// represents a file that will be uploaded to the app
/// takes [path] the path of the file inside the device
/// [type] the type of the file generally one of:
/// * Video
/// * Image
/// [subtype] the mime type of the file generally one of:
/// * mp4
/// * png
/// * jpg
/// * etc..
///
class UploadFile{
  final String path;
  final String? type;
  final String? subtype;

  UploadFile({required this.path, this.type, this.subtype}) : assert(type == null || subtype != null , "Type and subtype must be both null or both not null");
}

/// a class that hold a generic API response the caller of this class is responsible for decoding
/// the [responseBody] into the [data] depending on the [code] of the resposne
/// the [code] is one of :
/// * CODE_SUCCESS
/// * CODE_SUCCESS_CREATED
/// * CODE_SUCCESS_NO_BODY
/// * CODE_BAD_REQUEST
/// * CODE_NOT_FOUND
/// * CODE_TIMEOUT
/// * CODE_NO_INTERNET
/// * CODE_NOT_AUTHORIZED
/// * CODE_UNKNOWN
class ApiResponse<T> {
  T? data;
  int code;
  String? responseBody;

  ApiResponse({
    this.data,
    required this.code,
    required this.responseBody,
  });

  void log(){
    print("ApiResponse{code: $code , data: $data , body: $responseBody}");
  }

  //TODO: add codes here
  static const int CODE_SUCCESS = 200;
  static const int CODE_SUCCESS_CREATED = 201;
  static const int CODE_SUCCESS_NO_BODY = 204;
  static const int CODE_BAD_REQUEST = 400;
  static const int CODE_NOT_FOUND = 404;
  static const int CODE_TIMEOUT = 1000;
  static const int CODE_NO_INTERNET = 1001;
  static const int CODE_NOT_AUTHORIZED = 401;
  static const int CODE_UNKNOWN = -1;

}

/// represents a string API path in the backend server
/// takes only one parameter [_path] the path in the api
class ApiPath{
  final String _path;

  /// converts this object into its right [Uri], while encoding
  /// the link with the [params]
  Uri url({Map<String,dynamic>? params}) {
    return Uri.https(API_LINK , _path , params);
  }

  /// generates an [ApiPath] from a string
  static ApiPath fromString(String str){
    return ApiPath._(str);
  }

  /// formats a the [_path] using String formatting and returns
  /// an [ApiPath] with the new formatted string
  ApiPath format(List list){
    String str;
    str = sprintf(_path,list);
    return ApiPath._(str);
  }

  /// adds a directory to this [ApiPath]
  /// takes one input [directory] the directory to append
  ApiPath appendDirectory(String directory) => ApiPath._("$_path/$directory");

  const ApiPath._(String p) : _path = p;

  //TODO: add paths here
  static ApiPath checkExistedEmail       = const ApiPath._("/api/user/existedEmailOrUsername");
  static ApiPath signUp                  = const ApiPath._("/api/user/signup");
  static ApiPath checkBirthDate          = const ApiPath._("/api/user/checkBirthDate");
  static ApiPath confirmEmail            = const ApiPath._("/api/user/confirmEmail");
  static ApiPath verifyEmail             = const ApiPath._("/api/user/verifyEmail");
  static ApiPath resendConfirmEmail      = const ApiPath._("/api/user/resendConfirmEmail");
  static ApiPath forgotPassword          = const ApiPath._("/api/user/forgotpassword");
  static ApiPath resetPassword           = const ApiPath._("/api/user/resetpassword");
  static ApiPath checkForgotPasswordCode = const ApiPath._("api/user/checkPasswordResetToken");
  static ApiPath assignPassword          = const ApiPath._("/api/user/AssignPassword");
  static ApiPath assignUsername          = const ApiPath._("/api/user/AssignUsername");
  static ApiPath updatePassword          = const ApiPath._("/api/user/updatePassword");
  static ApiPath verifyPassword          = const ApiPath._("/api/user/confirmPassword");
  static ApiPath updateUsername          = const ApiPath._("/api/user/updateUsername");
  static ApiPath updateEmail             = const ApiPath._("/api/user/updateEmail");
  static ApiPath login                   = const ApiPath._("/api/user/login");
  static ApiPath google                  = const ApiPath._("/api/user/googleAuth");
  static ApiPath profileImage            = const ApiPath._("/api/user/profile/image");
  static ApiPath followingTweets         = const ApiPath._("/api/homepage/following");
  static ApiPath followUser              = const ApiPath._("/api/user/%s/follow");
  static ApiPath unfollowUser            = const ApiPath._("/api/user/%s/unfollow");
  static ApiPath muteUser                = const ApiPath._("/api/user/%s/mute");
  static ApiPath unmuteUser              = const ApiPath._("/api/user/%s/unmute");
  static ApiPath blockUser               = const ApiPath._("/api/user/%s/block");
  static ApiPath unblockUser             = const ApiPath._("/api/user/%s/unblock");
  static ApiPath createTweet             = const ApiPath._("/api/tweets/");
  static ApiPath likeTweet               = const ApiPath._("/api/tweets/like");
  static ApiPath unlikeTweet             = const ApiPath._("/api/tweets/unlike");
  static ApiPath tweetLikers             = const ApiPath._("/api/tweets/likers");
  static ApiPath comments                = const ApiPath._("/api/tweets/replies/%s");
  static ApiPath retweet                 = const ApiPath._("/api/tweets/retweet");
  static ApiPath unretweet               = const ApiPath._("/api/tweets/unretweet");
  static ApiPath media                   = const ApiPath._("/api/media");
  static ApiPath updateUserInfo          = const ApiPath._("/api/user/profile");
  static ApiPath currUserProfile         = const ApiPath._("/api/user/profile");
  static ApiPath userProfile             = const ApiPath._("/api/user/profile/%s");
  static ApiPath userProfileWithID       = const ApiPath._("/api/user/profileById/%s");
  static ApiPath userFollowers           = const ApiPath._("/api/user/profile/%s/followers");
  static ApiPath userFollowings          = const ApiPath._("/api/user/profile/%s/followings");
  static ApiPath userBlockList           = const ApiPath._("/api/user/blockList");
  static ApiPath userMutedList           = const ApiPath._("/api/user/mutedList");
  static ApiPath banner                  = const ApiPath._("/api/user/profile/banner");
  static ApiPath userProfileTweets       = const ApiPath._("/api/profile/%s/tweets");
  static ApiPath userProfileReplies      = const ApiPath._("/api/user/profile/%s/tweetsWithReplies");
  static ApiPath userProfileLikes        = const ApiPath._("/api/profile/%s/likes");
  static ApiPath mentions                = const ApiPath._("/api/homepage/mention");
  static ApiPath tweetRetweeters         = const ApiPath._("/api/tweets/retweeters/%s");
  static ApiPath searchUsers             = const ApiPath._("/api/user/search");
  static ApiPath searchTweets            = const ApiPath._("/api/tweets/search/%s");
  static ApiPath searchTags              = const ApiPath._("/api/trends/search");
  static ApiPath deleteTweet             = const ApiPath._("/api/tweets/%s");
  static ApiPath chatAll                 = const ApiPath._("/api/user/chat/all");
  static ApiPath chatMessages            = const ApiPath._("/api/user/chat/%s");
  static ApiPath chatMessagesBefore      = const ApiPath._("/api/user/chat/messagesBeforeCertainTime/%s");
  static ApiPath chatMessagesAfter       = const ApiPath._("/api/user/chat/messagesAfterCertainTime/%s");
  static ApiPath getTweet                = const ApiPath._("/api/tweets/%s");
  static ApiPath chatSearch              = const ApiPath._("/api/user/chat/search");
  static ApiPath searchTrends            = const ApiPath._("/api/trends/%s");
  static ApiPath tweetOwnerId            = const ApiPath._("/api/tweets/tweetOwner/%s");
  static ApiPath getAllTrends            = const ApiPath._("/api/trends/all");
  static ApiPath notifications           = const ApiPath._("/api/user/notifications");
  static ApiPath notificationsCount      = const ApiPath._("/api/user/notifications/unseenCount");
  static ApiPath notificationsMarkALl    = const ApiPath._("/api/user/notifications/markAllAsSeen");

}



/// a class that provided an abstract utility functions to deal with the backend API calls
///
class Api {

  /// inserts an authorization header using the [token] while also adding the JSON content header
  static Map<String,String> getTokenWithJsonHeader(String token){
    return getJsonHeader({
      "authorization" : token
    });
  }

  /// inserts an authorization header using the [token]
  static Map<String,String> getTokenHeader(String token){
    return {
      "authorization" : token
    };
  }

  /// adds the [JSON_TYPE_HEADER] to the headers
  static Map<String,String> getJsonHeader(Map<String,String> m){
    Map<String,String> map ={};
    map.addAll(m);
    map.addAll(JSON_TYPE_HEADER);
    return map;
  }

  /// a header that defines a JSON content type used in API communication
  static final Map<String,String> JSON_TYPE_HEADER = {"Content-Type": "application/json"};

  /// converts an error code to string
  /// takes one input [code] the code
  /// of the error to convert
  static String errorToString(int code){
    switch (code){
      case ApiResponse.CODE_NOT_FOUND: return "Not found";
      case ApiResponse.CODE_NO_INTERNET: return "No Internet Connection";
      case ApiResponse.CODE_TIMEOUT: return "Request Timed out";
      case ApiResponse.CODE_UNKNOWN: return "Unknown Error happened";
      case ApiResponse.CODE_BAD_REQUEST: return "Bad Request";
      default: return "Error [$code]";
    }
  }

  /// the actual implementation of the POST with no files functionality
  /// takes [url] the URL address of the end point
  /// [headers] the headers that will be used in the request
  /// [body] the body that will be used (normally a json string)
  /// [encoding] the content encoding (normally UTF8)
  static Future<ApiResponse<T>> _apiPostNoFilesImpl<T>(Uri url , Map<String,String>? headers , Object? body , Encoding encoding) async {
    try {
      var response = await http.post(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      ).timeout(API_TIMEOUT);
      return ApiResponse<T>(code: response.statusCode, responseBody: response.body);
    } on SocketException {
      return ApiResponse<T>(code: ApiResponse.CODE_NO_INTERNET, responseBody: null);
    } on TimeoutException {
      return ApiResponse<T>(code: ApiResponse.CODE_TIMEOUT, responseBody: null);
    } on Error catch (e) {
      print(e);
      return ApiResponse<T>(code: ApiResponse.CODE_UNKNOWN, responseBody: null);
    }
  }

  /// the actual implementation of the POST with file functionality
  /// takes [url] the URL address of the end point
  /// [headers] the headers that will be used in the request
  /// [body] the body that will be used (normally a json string)
  /// [files] the files to upload with the request
  /// [encoding] the content encoding (normally UTF8)
  static Future<ApiResponse<T>> _apiPostFilesImpl<T>(Uri url , Map<String,String>? headers , Object? body , List<http.MultipartFile> files , Encoding encoding) async {
    try {
      var request = http.MultipartRequest("POST" , url);
      request.headers.addAll(headers ?? {});
      if (body != null) {
        if (body is Map<String , String>){
          request.fields.addAll(body);
        }else{
          print("_apiPostFilesImpl: tried to add a body that is not a map");
        }
      }
      request.files.addAll(files);

      var response = await request.send();
      var response2 = await http.Response.fromStream(response);
      return ApiResponse<T>(code: response.statusCode, responseBody: String.fromCharCodes(response2.bodyBytes));
    } on SocketException {
      return ApiResponse<T>(code: ApiResponse.CODE_NO_INTERNET, responseBody: null);
    } on TimeoutException{
      return ApiResponse<T>(code: ApiResponse.CODE_TIMEOUT, responseBody: null);
    } on Error catch (e) {
      print(e);
      return ApiResponse<T>(code: ApiResponse.CODE_UNKNOWN, responseBody: null);
    }
  }

  /// the API POST function interface
  /// takes :
  /// [path] an API path for the end point
  /// [params] link params used in the request
  /// [headers] headers used in the request
  /// [body] the request body
  /// [files] the files to upload
  /// [encoding] the content encoding of the body
  static Future<ApiResponse<T>> apiPost<T>(
      ApiPath path ,
      {
        Map<String,dynamic>? params ,
        Map<String,String>? headers ,
        Object? body ,
        List<http.MultipartFile>? files ,
        Encoding? encoding ,
      }
      ){

    encoding ??= Encoding.getByName("utf-8");
    if (files == null){ //not an upload request
      return _apiPostNoFilesImpl<T>(path.url(params: params) , headers , body , encoding!);
    }
    return _apiPostFilesImpl<T>(path.url(params: params) , headers , body , files , encoding!);
  }

  /// the actual implementation of the GET with no files functionality
  /// takes [url] the URL address of the end point
  /// [headers] the headers that will be used in the request
  /// [body] the body that will be used (normally a json string)
  /// [encoding] the content encoding (normally UTF8)
  static Future<ApiResponse<T>> _apiGetNoFilesImpl<T>(Uri url , Map<String,String>? headers) async {
    try{
      var response = await http.get(
        url,
        headers: headers,
      ).timeout(API_TIMEOUT);
      //dynamic responsePayload = json.decode(response.body);
      return ApiResponse<T>(code: response.statusCode, responseBody: response.body);
    } on SocketException {
      return ApiResponse<T>(code: ApiResponse.CODE_NO_INTERNET, responseBody: null);
    } on TimeoutException {
      return ApiResponse<T>(code: ApiResponse.CODE_TIMEOUT, responseBody: null);
    } on Error catch (e) {
      print(e);
      return ApiResponse<T>(code: ApiResponse.CODE_UNKNOWN, responseBody: null);
    }
  }

  /// the API GET function interface
  /// takes :
  /// [path] an API path for the end point
  /// [params] link params used in the request
  /// [headers] headers used in the request
  static Future<ApiResponse<T>> apiGet<T>(
      ApiPath path ,
      {
        Map<String,dynamic>? params ,
        Map<String,String>? headers ,
      }
      ){

    headers ??= JSON_TYPE_HEADER;

    return _apiGetNoFilesImpl<T>(path.url(params: params) , headers );
  }

  /// the actual implementation of the PATCH with no files functionality
  /// takes [url] the URL address of the end point
  /// [headers] the headers that will be used in the request
  /// [body] the body that will be used (normally a json string)
  /// [encoding] the content encoding (normally UTF8)
  static Future<ApiResponse<T>> _apiPatchNoFilesImpl<T>(Uri url , Map<String,String>? headers , Object? body , Encoding encoding) async {
    try {
      var response = await http.patch(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      ).timeout(API_TIMEOUT);
      return ApiResponse<T>(code: response.statusCode, responseBody: response.body);
    } on SocketException {
      return ApiResponse<T>(code: ApiResponse.CODE_NO_INTERNET, responseBody: null);
    } on TimeoutException {
      return ApiResponse<T>(code: ApiResponse.CODE_TIMEOUT, responseBody: null);
    } on Error catch (e) {
      print(e);
      return ApiResponse<T>(code: ApiResponse.CODE_UNKNOWN, responseBody: null);
    }
  }

  /// the actual implementation of the PATCH with file functionality
  /// takes [url] the URL address of the end point
  /// [headers] the headers that will be used in the request
  /// [body] the body that will be used (normally a json string)
  /// [files] the files to upload with the request
  /// [encoding] the content encoding (normally UTF8)
  static Future<ApiResponse<T>> _apiPatchFilesImpl<T>(Uri url , Map<String,String>? headers , Object? body , List<http.MultipartFile> files , Encoding encoding) async {
    try {
      var request = http.MultipartRequest("PATCH" , url);
      request.headers.addAll(headers ?? {});
      if (body != null) {
        if (body is Map<String , String>){
          request.fields.addAll(body);
        }else{
          print("_apiPostFilesImpl: tried to add a body that is not a map");
        }
      }
      request.files.addAll(files);

      var response = await request.send();
      var response2 = await http.Response.fromStream(response);
      return ApiResponse<T>(code: response.statusCode, responseBody: String.fromCharCodes(response2.bodyBytes));
    } on SocketException {
      return ApiResponse<T>(code: ApiResponse.CODE_NO_INTERNET, responseBody: null);
    } on TimeoutException{
      return ApiResponse<T>(code: ApiResponse.CODE_TIMEOUT, responseBody: null);
    } on Error catch (e) {
      print(e);
      return ApiResponse<T>(code: ApiResponse.CODE_UNKNOWN, responseBody: null);
    }
  }

  /// the API PATCH function interface
  /// takes :
  /// [path] an API path for the end point
  /// [params] link params used in the request
  /// [headers] headers used in the request
  /// [body] the request body
  /// [files] the files to upload
  /// [encoding] the content encoding of the body
  static Future<ApiResponse<T>> apiPatch<T>(
      ApiPath path ,
      {
        Map<String,dynamic>? params ,
        Map<String,String>? headers ,
        Object? body ,
        List<http.MultipartFile>? files ,
        Encoding? encoding ,
      }
      ){
    encoding ??= Encoding.getByName("utf-8");
    if (files == null){ //not an upload request
      return _apiPatchNoFilesImpl<T>(path.url(params: params) , headers , body , encoding!);
    }
    return _apiPatchFilesImpl<T>(path.url(params: params) , headers , body , files , encoding!);
  }

  /// the actual implementation of the DELETE with no files functionality
  /// takes [url] the URL address of the end point
  /// [headers] the headers that will be used in the request
  /// [encoding] the content encoding (normally UTF8)
  static Future<ApiResponse<T>> _apiDeleteNoFilesImpl<T>(Uri url , Map<String,String>? headers , Encoding encoding) async {
    try {
      var response = await http.delete(
        url,
        headers: headers,
        encoding: encoding,
      ).timeout(API_TIMEOUT);
      return ApiResponse<T>(code: response.statusCode, responseBody: response.body);
    } on SocketException {
      return ApiResponse<T>(code: ApiResponse.CODE_NO_INTERNET, responseBody: null);
    } on TimeoutException {
      return ApiResponse<T>(code: ApiResponse.CODE_TIMEOUT, responseBody: null);
    } on Error catch (e) {
      print(e);
      return ApiResponse<T>(code: ApiResponse.CODE_UNKNOWN, responseBody: null);
    }
  }

  /// the API DELETE function interface
  /// takes :
  /// [path] an API path for the end point
  /// [params] link params used in the request
  /// [headers] headers used in the request
  /// [encoding] the content encoding of the body
  static Future<ApiResponse<T>> apiDelete<T>(
      ApiPath path ,
      {
        Map<String,dynamic>? params ,
        Map<String,String>? headers ,
        Encoding? encoding ,
      }
      ){
    encoding ??= Encoding.getByName("utf-8");

    return _apiDeleteNoFilesImpl<T>(path.url(params: params) , headers , encoding!);
  }

}