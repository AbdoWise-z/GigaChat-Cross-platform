
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/home/pages/feed/feed-home-tab.dart';
import 'package:gigachat/pages/home/widgets/FloatingActionMenu.dart';
import 'package:gigachat/pages/profile/edit-profile.dart';
import 'package:gigachat/pages/profile/profile-image-view.dart';
import 'package:gigachat/pages/profile/widgets/app-bar-icon.dart';
import 'package:gigachat/pages/profile/widgets/avatar.dart';
import 'package:gigachat/pages/profile/widgets/banner.dart';
import 'package:gigachat/pages/profile/widgets/interact.dart';
import 'package:gigachat/pages/profile/widgets/tab-bar.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/widgets/feed-component/feed.dart';
import 'package:gigachat/pages/profile/widgets/follow-button.dart';
import 'package:intl/intl.dart';
import '../../api/user-class.dart';

class UserProfile extends StatefulWidget {
  final String username;
  final bool isCurrUser;
  const UserProfile({Key? key, required this.username, required this.isCurrUser}) : super(key: key);

  static const pageRoute = '/user-profile';

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with TickerProviderStateMixin {

  //user details
  late String name;
  late String username;
  late String avatarImageUrl;
  late String bannerImageUrl;
  late String bio;
  late String website;
  String location = "Cairo, Egypt";  //its not a feature so its constant forever, looks cool tho
  late DateTime birthDate;
  late DateTime joinedDate;
  late int following;
  late int followers;
  //only wanted user details
  late bool? isCurrUserBlocked;
  late bool? isWantedUserBlocked;
  late bool? isCurrUserMuted;
  late bool? isWantedUserMuted;
  late bool? isWantedUserFollowed;
  late bool? isCurrUser;


  //page details
  bool loading = true;
  ScrollController scrollController = ScrollController();
  TabController? tabController;
  bool collapsed = false;
  bool showName = false;
  double avatarRadius = 35;
  EdgeInsetsGeometry avatarPadding = const EdgeInsets.fromLTRB(8, 122, 0, 0);
  int prevTabIndex = 0;
  List<bool> isLoaded = [true,false,false,false];

  double max = 317;

  //get user data
  void getData() async {
    setState(() {
      loading = true;
    });
    Auth auth = Auth.getInstance(context);
    var res = widget.isCurrUser? await Account.apiCurrUserProfile(auth.getCurrentUser()!.auth!) :
        await Account.apiUserProfile(auth.getCurrentUser()!.auth!, widget.username);
    User u = res.data!;

    name = u.name;
    username = u.id;
    avatarImageUrl = u.iconLink;
    bannerImageUrl = u.bannerLink;
    birthDate = u.birthDate!;
    joinedDate = u.joinedDate!;
    following = u.following;
    followers = u.followers;
    bio = u.bio;
    max = bio != ""? 390 : 317;
    website = u.website;
    isCurrUserBlocked = u.isCurrUserBlocked;
    isWantedUserBlocked = u.isWantedUserBlocked;
    isCurrUserMuted = u.isCurrUserMuted;
    isWantedUserMuted = u.isWantedUserMuted;
    isWantedUserFollowed = u.isWantedUserFollowed;
    isCurrUser = u.isCurrUser;


    setState(() {
      loading = false;
    });
  }

  void onTapBarClick(int index) {
    if(prevTabIndex != index){
      prevTabIndex = index;
      if(index == 1 && !isLoaded[1]){
        scrollController.animateTo(295, duration: const Duration(milliseconds: 10), curve: Curves.easeInOut);
        isLoaded[1] = true;
     }
      if(index == 2 && !isLoaded[2]){
        scrollController.animateTo(295, duration: const Duration(milliseconds: 10), curve: Curves.easeInOut);
        isLoaded[2] = true;
      }
      if(index == 3 && !isLoaded[3]){
        scrollController.animateTo(295, duration: const Duration(milliseconds: 10), curve: Curves.easeInOut);
        isLoaded[3] = true;
      }
    }
  }

  @override
  void initState()  {
    tabController = TabController(length: 4, vsync: this);
    getData();
    super.initState();
  }

  //TODO: get tweets
  //TODO: refresh tweets
  //TODO: onNotification func (when scrolling so fast)

  @override
  Widget build(BuildContext context) {

    return loading? const BlockingLoadingPage():
    Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: showName? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
              style: const TextStyle(
                  fontSize: 23,
                  color: Colors.white
              ),
            ),
            const Text("2 Posts",
              style: TextStyle(
                color: Colors.white,
              ),
            ), //TODO: num of posts
          ],
        ) : null,
        backgroundColor: Colors.transparent,
        leading: ProfileAppBarIcon(
          toolTip: 'Navigate Up',
          icon: Icons.arrow_back,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        leadingWidth: 60,
        actions: (showName && !widget.isCurrUser && isWantedUserFollowed != null && !isWantedUserFollowed!) ?
        <Widget>[
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: FollowButton(
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: (){
                  //TODO: follow user
                },
              )
          ),
        ] :
        <Widget>[
          ProfileAppBarIcon(
            icon: Icons.search,
            onPressed: (){
              //TODO: navigate to search page with user filter
            },
            toolTip: 'Search',
          ),
          ProfileAppBarIcon(
            icon: Icons.more_vert,
            toolTip: 'Menu',
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(6, 5, 5, 0),
                items: widget.isCurrUser? <PopupMenuItem>[ //doesn't do anything just for looks :p
                  PopupMenuItem(
                    child: const Text("Share"),
                    onTap: (){},
                  ),
                  PopupMenuItem(
                    child: const Text("Draft"),
                    onTap: (){},
                  ),
                  PopupMenuItem(
                    child: const Text("Lists you're on"),
                    onTap: (){},
                  )
                ] : <PopupMenuItem>[
                  isWantedUserMuted != null && isWantedUserMuted!?
                  PopupMenuItem(
                    child: const Text("Unmute"),
                    onTap: (){}, //TODO: unmute user
                  ): PopupMenuItem(
                    child: const Text("Mute"),
                    onTap: (){}, //TODO: mute user
                  ),
                  isWantedUserBlocked != null && isWantedUserBlocked!?
                  PopupMenuItem(
                    child: const Text("Unblock"),
                    onTap: (){}, //TODO: unblock user
                  ):
                  PopupMenuItem(
                    child: const Text("Block"),
                    onTap: (){}, //TODO: block user
                  ),
                ],
              );
            },
          ),
        ],
        flexibleSpace: collapsed? FlexibleSpaceBar(
          background: ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
            child: Image.network(bannerImageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ) : null
      ),

      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification){
          double pos = scrollController.position.pixels;
          if(pos < max){
            setState(() {
              collapsed = pos > 80 ? true : false;
              showName = pos > 162 ? true : false;
              avatarRadius = pos < 140? 35 - 0.2 * pos : 20;
              avatarPadding = pos < 140? EdgeInsets.fromLTRB(8 + 0.2 * pos, 122 + 0.46 * pos, 0, 0) :
              const EdgeInsets.fromLTRB(24, 160, 0, 0);
            });
          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: ()async{
            //TODO: refresh user page
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        ProfileBanner(
                          bannerImageUrl: bannerImageUrl,
                          onTap: ()async{
                             var res = await Navigator.push(context,
                                 MaterialPageRoute(builder: (context) =>
                                     ProfileImageView(
                                       isProfileAvatar: false,
                                       imageUrl: bannerImageUrl,
                                       avatarImageUrl: avatarImageUrl,
                                       name: name,
                                       birthDate: birthDate,
                                       bio: bio,
                                       website: website,
                                     )
                                 )
                             );
                             if(res != null){
                               setState(() {
                                 name = res["name"];
                                 bio = res["bio"];
                                 website = res["website"];
                                 birthDate = res["birthDate"];
                                 bannerImageUrl = res["bannerImageUrl"];
                                 avatarImageUrl = res["avatarImageUrl"];
                               });
                             }
                          },
                        ),
                        Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ProfileInteract(
                                        isCurrUser: widget.isCurrUser,
                                        isWantedUserFollowed : isWantedUserFollowed,
                                        isWantedUserBlocked : isWantedUserBlocked,
                                        onTapEditProfile: ()async{
                                          var res = await Navigator.push(context,
                                              MaterialPageRoute(builder: (context) =>
                                                  EditProfile(
                                                    name: name,
                                                    bannerImageUrl: bannerImageUrl,
                                                    avatarImageUrl: avatarImageUrl,
                                                    bio: bio,
                                                    website: website,
                                                    birthDate: birthDate,
                                                  )
                                              ));
                                          if(res != null){
                                            setState(() {
                                              name = res["name"];
                                              bio = res["bio"];
                                              website = res["website"];
                                              birthDate = res["birthDate"];
                                              bannerImageUrl = res["bannerImageUrl"];
                                              avatarImageUrl = res["avatarImageUrl"];
                                            });
                                          }
                                        },
                                        onTapDM: (){}, //TODO: DM user
                                        onTapFollow: (){}, //TODO: follow user
                                        onTapUnfollow: (){}, //TODO: unfollow user
                                      ),
                                      Text(
                                        name,
                                        style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text("@$username"),
                                      bio == "" ? const Text("") :
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0,10,0,0),
                                        child: SizedBox(
                                          height: 80,
                                            child: Text(bio)
                                        ),
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 15,),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Text(location),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10,),
                                          Row(
                                            children: [
                                              const Icon(Icons.cake, size: 15,),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Text("Born ${DateFormat.yMMMMd('en_US').format(birthDate )}"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.date_range, size: 15,),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Text("Joined ${DateFormat.yMMMMd('en_US').format(joinedDate)}"),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10,),
                                          Row(
                                            children: [
                                              const Icon(CupertinoIcons.link, size: 15,),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Text(website), //TODO: change later (detect urls)
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 15,),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              //TODO: list of Following
                                            },
                                            splashFactory: NoSplash.splashFactory,
                                            child: Row(
                                              children: [
                                                Text(
                                                  "$following",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Text(" Following"),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10,),
                                          InkWell(
                                            onTap: (){
                                              //TODO: list of Followers
                                            },
                                            splashFactory: NoSplash.splashFactory,
                                            child: Row(
                                              children: [
                                                Text(
                                                  "$followers",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Text(" Followers"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      ProfileTabBar(
                                        tabController: tabController,
                                      ),
                                      SizedBox(
                                        height: 1000, //TODO: user feed (change height dynamically every getTweets request)
                                        child: TabBarView(
                                            controller: tabController,
                                            children: [
                                              Container(color: Colors.red,child: Center(child: Text("1"),),),
                                              Container(color: Colors.red,child: Center(child: Text("2"),),),
                                              Container(color: Colors.red,child: Center(child: Text("3"),),),
                                              Container(color: Colors.red,child: Center(child: Text("4"),),),
                                            ]
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ],
                    ),
                    ProfileAvatar(
                      avatarImageUrl: avatarImageUrl,
                      avatarPadding: avatarPadding,
                      avatarRadius: avatarRadius,
                      onTap: () async {
                        var res = await Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                                ProfileImageView(isProfileAvatar: true, imageUrl: avatarImageUrl)
                            )
                        );
                        if(res != null){
                          setState(() {
                            avatarImageUrl = res;
                          });
                        }
                      },
                    ),
                  ],
                )
              ),
              Visibility(
                visible: scrollController.hasClients && scrollController.position.pixels > (max - 5),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10,80,10,10),
                  child: Container(
                    color: ThemeProvider.getInstance(context).isDark() ? Colors.black : Colors.white,
                    width: double.infinity,
                    child: ProfileTabBar(
                      tabController: tabController,
                      onTap: onTapBarClick,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FeedHomeTab().getFloatingActionButton(context),  //TODO: change later
    );
  }
}


