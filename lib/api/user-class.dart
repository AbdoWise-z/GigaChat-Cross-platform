
/// This is the [User] model in our app
class User {

  /// The unique username of [User] (can be changed)
  String id;

  /// Unique id of [User] (can't be changed)
  String? mongoID;

  /// Token of [User]
  String? auth;

  /// [User]'s Info
  String name;
  String email;
  String bio;
  String iconLink;
  String bannerLink;
  String location;
  String website;
  DateTime? birthDate;
  DateTime? joinedDate;
  int followers;
  int following;
  int numOfPosts;
  int numOfLikes;

  /// [User]'s interactions with other [User]s
  /// * Curr for Currently logged in [User]
  /// * Wanted for other [User]s
  bool? isCurrUserBlocked;
  bool? isWantedUserBlocked;
  bool? isWantedUserMuted;
  bool? isFollowed;
  bool? isCurrUser;

  /// Indicates whether this [User] follows the curr [User] or not
  bool? isFollowingMe;

  /// Currently not used
  bool active;

  User({
    this.id = "username",
    this.mongoID = "DEFAULT_MONGO_ID",
    this.name = "Nickname",
    this.auth = "",
    this.email = "...",
    this.bio = "",
    this.iconLink = "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",
    this.bannerLink = "",
    this.location = "Egypt, Cairo",  //const as its not a feature
    this.website = "Gigachat",       //const as its not a feature
    this.birthDate,
    this.joinedDate,
    this.followers = 0,
    this.following = 0,
    this.active = false,
    this.isCurrUser,
    this.isCurrUserBlocked = false,
    this.isWantedUserBlocked = false,
    this.isFollowed = false,
    this.isWantedUserMuted = false,
    this.numOfLikes = 0,
    this.numOfPosts = 0,
    this.isFollowingMe = false,
  });

}