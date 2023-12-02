import 'api.dart';
import 'dart:io';
import 'dart:convert';

class Media {

  static Future<ApiResponse<List<String>>> apiMedia(List<File> files,String token) async{
    Map<String,String> headers = Api.getTokenWithJsonHeader("Bearer $token");
    print(files[0].path);
    List<String>filePaths = files.map((e) => e.path).toList();
    var k = await Api.apiPost<List<String>>(
        ApiPath.media,
        body: json.encode({
          "media" : files[0].path,
        }),
      headers: headers,
    );
    if(k.code == ApiResponse.CODE_SUCCESS_CREATED){
      var res = json.decode(k.responseBody!);
      print(res);
      k.data = res["urls"];
    }else{
      print(k.code);
      k.data = null;
    }
    return k;
  }

}