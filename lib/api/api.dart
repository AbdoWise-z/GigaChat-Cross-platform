//all of the API classes will be defined here
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:gigachat/base.dart';


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

class User {
  String id;
  String name;
  String auth;
  String email;
  String bio;
  String iconLink;
  String bannerLink;
  String location;
  String website;
  String birthDate;
  String joinedDate;

  int followers;
  int following;
  bool active;

  User({
    this.id = "@Abdo-ww",
    this.name = "Abdo",
    this.auth = "AUTH KEY",
    this.email = "...",
    this.bio = "the coolest man on planet earth :PEPECOOL:",
    this.iconLink = "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",
    this.bannerLink = "",
    this.location = "hell",
    this.website = "www.Abdo.com",
    this.birthDate = "9-18-2002",
    this.joinedDate = "9-17-2002",
    this.followers = 0,
    this.following = 0,
    this.active = false,
  });

}

class ApiPath{
  final String _path;
  Uri url({Map<String,dynamic>? params}) {
    return Uri.http(API_LINK , _path , params);
  }

  const ApiPath._(String p) : _path = p;

  //TODO: add paths here
  static ApiPath checkExistedEmail       = const ApiPath._("/api/user/checkExistedEmail");
  static ApiPath signUp                  = const ApiPath._("/api/user/signup");
  static ApiPath checkBirthDate          = const ApiPath._("/api/user/checkBirthDate");
  static ApiPath confirmEmail            = const ApiPath._("/api/user/confirmEmail");
  static ApiPath resendConfirmEmail      = const ApiPath._("/api/user/resendConfirmEmail");
  static ApiPath assignPassword          = const ApiPath._("/api/user/AssignPassword");
  static ApiPath assignUsername          = const ApiPath._("/api/user/AssignUsername");
  static ApiPath login                   = const ApiPath._("/api/user/login");
  static ApiPath profileImage            = const ApiPath._("/api/user/profile/image");
  static ApiPath followingTweets            = const ApiPath._("/api/homepage/following");
  static ApiPath comments            = const ApiPath._("/api/tweets/replies/");
}

class Api {

  static Map<String,String> getTokenWithJsonHeader(String token){
    return getJsonHeader({
      "authorization" : token
    });
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

  static Future<ApiResponse<T>> _apiPostFilesImpl<T>(Uri url , Map<String,String>? headers , Object? body , Map<String,String> files , Encoding encoding) async {
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

      for ( MapEntry e in files.entries) {
        //TODO: maybe get the contentType and fileName too in the future ...
        request.files.add(
            await http.MultipartFile.fromPath(
              '${e.key}',
               '${e.value}'
            )
        );
      }

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
        Map<String,String>? files ,
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
        headers: headers
      ).timeout(API_TIMEOUT);

      Map<String, dynamic> responsePayload = json.decode(response.body);

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

  static Future<ApiResponse<T>> _apiGetFilesImpl<T>(Uri url , Map<String,String>? headers , Object? body , Map<String,String> files , Encoding encoding) async {
    try {
      var request = http.MultipartRequest("GET" , url);
      request.headers.addAll(headers ?? {});

      if (body != null) {
        if (body is Map<String , String>){
          request.fields.addAll(body);
        }else{
          print("_apiPostFilesImpl: tried to add a body that is not a map");
        }
      }

      for ( MapEntry e in files.entries) {
        //TODO: maybe get the contentType and fileName too in the future ...
        request.files.add(
            await http.MultipartFile.fromPath(
                '${e.key}',
                '${e.value}'
            )
        );
      }

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



  static Future<ApiResponse<T>> apiGet<T>(
      ApiPath path ,
      {
        Map<String,dynamic>? params ,
        Map<String,String>? headers ,
        Object? body ,
        Map<String,String>? files ,
        Encoding? encoding ,
      }
      ){

    encoding ??= Encoding.getByName("utf-8");
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

  static Future<ApiResponse<T>> _apiPatchFilesImpl<T>(Uri url , Map<String,String>? headers , Object? body , Map<String,String> files , Encoding encoding) async {
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

      for ( MapEntry e in files.entries) {
        request.files.add(
            await http.MultipartFile.fromPath(
                '${e.key}',
                '${e.value}'
            )
        );
      }

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
        Map<String,String>? files ,
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