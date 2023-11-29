
class User {
  String id;
  String name;
  String? auth;
  String email;
  String? bio;
  String iconLink;
  String? bannerLink;
  String location;
  String website;
  DateTime? birthDate;
  DateTime? joinedDate;

  int followers;
  int following;
  bool active;

  User({
    this.id = "@Abdo-ww",
    this.name = "Abdo",
    this.auth,
    this.email = "...",
    this.bio,
    this.iconLink = "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.webp",
    this.bannerLink,
    this.location = "hell",
    this.website = "www.Abdo.com",
    this.birthDate,
    this.joinedDate,
    this.followers = 0,
    this.following = 0,
    this.active = false,
  });

}