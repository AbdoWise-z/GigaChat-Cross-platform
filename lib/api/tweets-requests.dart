
import 'api.dart';
import "package:gigachat/api/user-class.dart";

class Tweet {
  static Future<ApiResponse<User>> apiSendTweet() async {
    return ApiResponse<User>(code: 0, responseBody: '');
  }
}