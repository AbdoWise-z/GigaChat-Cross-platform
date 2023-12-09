//TODO: add constants here
//const String API_LINK = "127.0.0.1:5000";
const String API_LINK = "backend.gigachat.cloudns.org";
const Duration API_TIMEOUT = Duration(seconds: 5);
const int DEFAULT_PAGE_COUNT = 5;
const String USER_DEFAULT_PROFILE = "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.jpg";

const String APP_NAME = "gigachat";

// global constants
const double LOGIN_PAGE_PADDING = 10.0;
const double CREATE_POST_POPUP_PADDING = 32;
const int MEDIA_UPLOAD_LIMIT = 4;
const double MAX_POST_LENGTH = 200;


// constants for the tweet widget
const int MAX_LINES_TO_SHOW = 8;

enum ProviderFunction{
  HOME_PAGE_TWEETS,
  PROFILE_PAGE_TWEETS,
  GET_TWEET_COMMENTS,
  SEARCH_USERS,
  SEARCH_TWEETS,
  NONE
}

enum ProviderResultType{
  USER_RESULT,
  TWEET_RESULT
}