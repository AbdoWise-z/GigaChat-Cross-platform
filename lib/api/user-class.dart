
class User {
  String id;
  String? mongoID;
  String name;
  String? auth;
  String email;
  String bio;
  String iconLink;
  String bannerLink;
  String location;
  String website;
  DateTime? birthDate;
  DateTime? joinedDate;
  bool? isCurrUserBlocked;
  bool? isWantedUserBlocked;
  bool? isWantedUserMuted;
  bool? isFollowed;
  bool? isCurrUser;
  bool? isBlocked;
  int followers;
  int following;
  int numOfPosts;
  int numOfLikes;
  bool active;

  User({
    this.id = "Abdo-ww",
    this.mongoID = "DEFAULT_MONGO_ID",
    this.name = "Abdo",
    this.auth = "moa",
    this.email = "...",
    this.bio = "",
    this.iconLink = "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",
    this.bannerLink = "",
    this.location = "Egypt, Cairo",
    this.website = "Gigachat",
    this.birthDate,
    this.joinedDate,
    this.followers = 0,
    this.following = 0,
    this.active = false,
    this.isCurrUser,
    this.isCurrUserBlocked,
    this.isWantedUserBlocked,
    this.isFollowed = false,
    this.isBlocked = false,
    this.isWantedUserMuted,
    this.numOfLikes = 0,
    this.numOfPosts = 0,
  });

}