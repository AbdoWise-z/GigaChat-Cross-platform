
import 'dart:convert';

import 'package:gigachat/api/api.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';


class Media {
  static Future<ApiResponse<List>> uploadMedia(String token , List<UploadFile> files , {void Function(ApiResponse<List>)? success , void Function(ApiResponse<List>)? error}) async {
    List<MultipartFile> fList = [];

    for (var upload in files){
      fList.add(
        await MultipartFile.fromPath(
          "media" ,
          upload.path ,
          contentType: upload.type != null ? MediaType(upload.type!, upload.subtype!) : null,
        ),
      );
    }

    if (fList.isEmpty){
      return ApiResponse<List<String>>(
        code: 0,
        data: [],
        responseBody: '',
      );
    }

    var res = await Api.apiPost<List>(
      ApiPath.media,
      files: fList,
      headers: Api.getTokenHeader("Bearer $token"),
    );

    //print("res: ${res.code} / ${res.responseBody}");

    if (res.code == ApiResponse.CODE_SUCCESS){
      var body = json.decode(res.responseBody!);
      res.data = body["data"]["usls"];
      if (success != null) success(res);
      return res;
    }

    if (error != null) error(res);
    return res;
  }
}