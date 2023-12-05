//all of the API classes will be defined here
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:gigachat/base.dart';
import 'package:sprintf/sprintf.dart';


class UploadFile{
  final String path;
  final String? type;
  final String? subtype;

  UploadFile({required this.path, this.type, this.subtype}) : assert(type == null || subtype != null , "Type and subtype must be both null or both not null");
}

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


class ApiPath{
  final String _path;
  Uri url({Map<String,dynamic>? params}) {
    return Uri.http(API_LINK , _path , params);
  }
  static ApiPath fromString(String str){
    return ApiPath._(str);
  }
  ApiPath format(List list){
    String str;
    str = sprintf(_path,list);
    return ApiPath._(str);
  }
  ApiPath appendDirectory(String directory) => ApiPath._("$_path/$directory");

  const ApiPath._(String p) : _path = p;

  //TODO: add paths here
  static ApiPath checkExistedEmail       = const ApiPath._("/api/user/existedEmailOrUsername");
  static ApiPath signUp                  = const ApiPath._("/api/user/signup");
  static ApiPath checkBirthDate          = const ApiPath._("/api/user/checkBirthDate");
  static ApiPath confirmEmail            = const ApiPath._("/api/user/confirmEmail");
  static ApiPath resendConfirmEmail      = const ApiPath._("/api/user/resendConfirmEmail");
  static ApiPath assignPassword          = const ApiPath._("/api/user/AssignPassword");
  static ApiPath assignUsername          = const ApiPath._("/api/user/AssignUsername");
  static ApiPath login                   = const ApiPath._("/api/user/login");
  static ApiPath profileImage            = const ApiPath._("/api/user/profile/image");
  static ApiPath followingTweets         = const ApiPath._("/api/homepage/following");
  static ApiPath followUser              = const ApiPath._("/api/user/%s/follow");
  static ApiPath unfollowUser            = const ApiPath._("/api/user/%s/unfollow");
  static ApiPath createTweet             = const ApiPath._("/api/tweets/");
  static ApiPath likeTweet               = const ApiPath._("/api/tweets/like");
  static ApiPath unlikeTweet             = const ApiPath._("/api/tweets/unlike");
  static ApiPath tweetLikers             = const ApiPath._("/api/tweets/likers");
  static ApiPath comments                = const ApiPath._("/api/tweets/replies/%s");
  static ApiPath retweet                 = const ApiPath._("/api/tweets/retweet");
  static ApiPath media                   = const ApiPath._("/api/media");
  static ApiPath updateUserInfo          = const ApiPath._("/api/user/profile");
  static ApiPath currUserProfile         = const ApiPath._("/api/user/profile");
  static ApiPath userProfile             = const ApiPath._("/api/user/profile/%s");
  static ApiPath banner                  = const ApiPath._("/api/user/profile/banner");
  static ApiPath userProfileTweets       = const ApiPath._("/api/profile/%s/tweets");
  static ApiPath tweetRetweeters         = const ApiPath._("/api/tweets/retweeters/%s");
  static ApiPath unretweet               = const ApiPath._("/api/tweets/unretweet");

}

class Api {

  static Map<String,String> getTokenWithJsonHeader(String token){
    return getJsonHeader({
      "authorization" : token
    });
  }

  static Map<String,String> getTokenHeader(String token){
    return {
      "authorization" : token
    };
  }

  static Map<String,String> getJsonHeader(Map<String,String> m){
    Map<String,String> map ={};
    map.addAll(m);
    map.addAll(JSON_TYPE_HEADER);
    return map;
  }



  static final Map<String,String> JSON_TYPE_HEADER = {"Content-Type": "application/json"};

  static String errorToString(int code){
    switch (code){
      case ApiResponse.CODE_NOT_FOUND: return "Not found";
      case ApiResponse.CODE_NO_INTERNET: return "No Internet Connection";
      case ApiResponse.CODE_TIMEOUT: return "Request Timed out";
      case ApiResponse.CODE_UNKNOWN: return "Unknown Error happend";
      case ApiResponse.CODE_BAD_REQUEST: return "Bad Request";
      default: return "Error [$code]";
    }
  }


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
    return _apiPostFilesImpl<T>(path.url() , headers , body , files , encoding!);
  }

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
    return _apiPatchFilesImpl<T>(path.url() , headers , body , files , encoding!);
  }

}