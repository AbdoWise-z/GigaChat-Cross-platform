
import 'dart:convert';

import 'package:gigachat/api/api.dart';
import 'package:gigachat/api/trend-data.dart';

class TrendRequests{

  static Future<Map<String , TrendData>> getAllTrends
      (String token, String page, String count) async {
    ApiPath path = ApiPath.getAllTrends;
    var headers = Api.getTokenWithJsonHeader("Bearer $token");
    ApiResponse response = await Api.apiGet(path,headers:headers,
        params: {
          "page": page,
          "count" : count
        }
    );

    if (response.code == ApiResponse.CODE_SUCCESS && response.responseBody != null){
      List res = jsonDecode(response.responseBody!)["data"];
      Map<String,TrendData> ret = {};
      for (var trend in res){
        ret.putIfAbsent(trend["title"],
                () =>  TrendData(
                    trendContent: trend["title"],
                    numberOfPosts: trend["count"])
        );
      }
      return ret;
    }
    else
    {
      return {};
    }

  }


}


