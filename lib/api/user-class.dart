
class User {
  String id;
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


  int followers;
  int following;
  int numOfPosts;
  int numOfLikes;
  bool active;

  User({
    this.id = "@Abdo-ww",
    this.name = "Abdo",
    this.auth = "moa",
    this.email = "...",
    this.bio = "",
    this.iconLink = "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",
    this.bannerLink = "https://cdn.custom-cursor.com/pa"
        "cks/7464/genshin-nahida-and-a-thousand-floating-dreams-pack.png",
    this.location = "hell",
    this.website = "www.Abdo.com",
    this.birthDate,
    this.joinedDate,
    this.followers = 0,
    this.following = 0,
    this.active = false,
    this.isCurrUser,
    this.isCurrUserBlocked,
    this.isWantedUserBlocked,
    this.isFollowed,
    this.isWantedUserMuted,
    this.numOfLikes = 0,
    this.numOfPosts = 0,
  });

}