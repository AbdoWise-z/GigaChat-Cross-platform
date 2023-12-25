
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/home/pages/chat/chat-page.dart';
import 'package:gigachat/pages/home/pages/feed/feed-home-tab.dart';
import 'package:gigachat/pages/posts/list-view-page.dart';
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
import 'package:gigachat/widgets/text-widgets/main-text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../api/user-class.dart';
import '../../base.dart';
import '../../util/Toast.dart';
import '../../widgets/feed-component/FeedWidget.dart';
import '../../widgets/feed-component/feed-controller.dart';

class UserProfile extends StatefulWidget {
  final String username;
  final bool isCurrUser;
  static const profileFeedPosts = 'profileFeedPosts/';
  static const profileFeedLikes = 'profileFeedLikes/';

  const UserProfile({Key? key, required this.username, required this.isCurrUser}) : super(key: key);

  static const pageRoute = '/user-profile';

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with TickerProviderStateMixin {

  //user details
  late String name;
  late String username;
  late String mongoID;
  late String avatarImageUrl;
  late String bannerImageUrl;
  late String bio;
  late String website;
  String location = "Cairo, Egypt";  //its not a feature so its constant forever, looks cool tho
                                     //yeah I can confirm it looks cool
  late DateTime birthDate;
  late DateTime joinedDate;
  late int following;
  late int followers;
  late int numOfPosts;
  late int numOfLikes;
  //only wanted user details
  late bool? isCurrUserBlocked;
  late bool? isWantedUserBlocked;
  late bool? isWantedUserMuted;
  late bool? isWantedUserFollowed;
  late bool? isCurrUser;
  late bool? isFollowingMe;


  //page details
  late Auth auth;
  bool loading = true;

  late ScrollController scrollController;
  late FeedController postsFeedController;
  late FeedController likesFeedController;

  late TabController tabController;

  int prevTabIndex = 0;
  List<bool> isLoaded = [true,false];

  double avatarRadius = 35;
  double showNamePosition = 162;
  double collapsePosition = 80;
  EdgeInsetsGeometry avatarPadding = const EdgeInsets.fromLTRB(8, 122, 0, 0);

  final ValueNotifier<double> scroll = ValueNotifier<double>(0);

  //get user data
  void getData() async {
    setState(() {
      loading = true;
    });

    Auth auth = Auth.getInstance(context);
    FeedProvider feedProvider = FeedProvider.getInstance(context);

    var res = widget.isCurrUser? await Account.apiCurrUserProfile(auth.getCurrentUser()!.auth!) :
        await Account.apiUserProfile(auth.getCurrentUser()!.auth!, widget.username);

    User u = res.data!;
    if (u.mongoID == "NOT FOUND"){
      Toast.showToast(context, "User not found");
      Navigator.pop(context);
    }

    name = u.name;
    username = u.id;
    avatarImageUrl = u.iconLink;
    bannerImageUrl = u.bannerLink;
    birthDate = u.birthDate!;
    joinedDate = u.joinedDate!;
    following = u.following;
    followers = u.followers;
    bio = u.bio;
    website = u.website;
    isCurrUserBlocked = u.isCurrUserBlocked;
    isWantedUserBlocked = u.isWantedUserBlocked;
    isWantedUserMuted = u.isWantedUserMuted;
    isWantedUserFollowed = u.isFollowed;
    isCurrUser = u.isCurrUser;
    numOfPosts = u.numOfPosts;
    numOfLikes = u.numOfLikes;
    mongoID = u.mongoID!;
    isFollowingMe = u.isFollowingMe;


    scrollController = ScrollController();
    scrollController.addListener(() async {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && (widget.isCurrUser
          || (isCurrUser != null && isCurrUser!)
          || ((isWantedUserBlocked != null && !isWantedUserBlocked!) && (isCurrUserBlocked != null && !isCurrUserBlocked!)))) {
        if(prevTabIndex == 0) {
           setState(() {
             postsFeedController.fetchingMoreData = true;
           });
          await postsFeedController.fetchFeedData(username: widget.username);
          setState(() {
            postsFeedController.fetchingMoreData = false;
          });
        }
        if(prevTabIndex == 1) {
          setState(() {
            likesFeedController.fetchingMoreData = true;
          });
          await likesFeedController.fetchFeedData(username: widget.username);
          setState(() {
            likesFeedController.fetchingMoreData = false;
          });
        }
        setState(() {});
      }
    });

    if(!context.mounted) return;

    postsFeedController = feedProvider.getFeedControllerById(
        context: context,
        id: UserProfile.profileFeedPosts + widget.username,
        providerFunction: ProviderFunction.PROFILE_PAGE_TWEETS,
        clearData: false,
    );
    postsFeedController.isInProfile = username == auth.getCurrentUser()!.id;
    postsFeedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);

    likesFeedController = feedProvider.getFeedControllerById(
        context: context,
        id: UserProfile.profileFeedLikes + widget.username,
        providerFunction: ProviderFunction.PROFILE_PAGE_LIKES,
        clearData: false
    );
    likesFeedController.isInProfile = username == auth.getCurrentUser()!.id;
    likesFeedController.setUserToken(Auth.getInstance(context).getCurrentUser()!.auth);

    postsFeedController.resetFeed();
    postsFeedController.updateFeeds();
    likesFeedController.resetFeed();
    likesFeedController.updateFeeds();

    setState(() {
      loading = false;
    });
  }

  void updateUserFeeds(){
    FeedProvider feedProvider = FeedProvider.getInstance(context);
    if(context.mounted) {
      if(username != auth.getCurrentUser()!.id){
        feedProvider.updateProfileFeed(context, UserProfile.profileFeedPosts,isCurrProfile: username == auth.getCurrentUser()!.id);
        feedProvider.updateProfileFeed(context, UserProfile.profileFeedLikes,isCurrProfile: username == auth.getCurrentUser()!.id);
      }
    }
  }

  void onTapBarClick(int index, int durationMS) {
    if(prevTabIndex != index){
      setState(() {
        prevTabIndex = index;
      });
      if(index == 1 && !isLoaded[1]){
        if(scrollController.position.pixels > 335 && bio == ""){
          scrollController.animateTo(335, duration: Duration(milliseconds: durationMS), curve: Curves.easeInOut);
        }
        else if(scrollController.position.pixels > 410 && bio != ""){
          scrollController.animateTo(410, duration: Duration(milliseconds: durationMS), curve: Curves.easeInOut);
        }
        isLoaded[1] = true;
     }
    }
  }

  void onEditProfileClick() async {
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
        getData();
        scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn
        );
        scroll.value = 0;
      });
    }
  }

  void onProfileAvatarClick() async {
    var res = await Navigator.push(context,
        MaterialPageRoute(builder: (context) =>
            ProfileImageView(
              isCurrUser: widget.isCurrUser || (isCurrUser != null && isCurrUser!),
              isProfileAvatar: true,
              imageUrl: avatarImageUrl,
            )
        )
    );
    if(res != null){
      setState(() {
        avatarImageUrl = res;
        getData();
        scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn
        );
        scroll.value = 0;
      });
    }
  }

  void followUser() async {
    await auth.follow(
      widget.username,
      success: (res){
        setState(() {
          isWantedUserFollowed = true;
          followers++;
          updateUserFeeds();
        });
      },
      error: (res){
        if(context.mounted){
          Toast.showToast(context, "Action failed. Please try again.");
        }
      }
    );
  }

  void unfollowUser() async {
    await auth.unfollow(
        widget.username,
        success: (res){
          setState(() {
            isWantedUserFollowed = false;
            followers--;
            updateUserFeeds();
          });
        },
        error: (res){
          if(context.mounted){
            Toast.showToast(context, "Action failed. Please try again.");
          }
        }
    );
  }

  void muteUser() async {
    await auth.mute(
      widget.username,
      success: (res){
        setState(() {
          isWantedUserMuted = true;
          updateUserFeeds();
          Toast.showToast(context, "You muted @${widget.username}.");
        });
      },
      error: (res){
        if(context.mounted){
          Toast.showToast(context, "Action failed. Please try again.");
        }
      }
    );
  }

  void unmuteUser() async {
    await auth.unmute(
        widget.username,
        success: (res){
          setState(() {
            isWantedUserMuted = false;
            updateUserFeeds();
            Toast.showToast(context, "You unmuted @${widget.username}.");
          });
        },
        error: (res){
          if(context.mounted){
            Toast.showToast(context, "Action failed. Please try again.");
          }
        }
    );
  }

  void blockUser() async {
    showDialog(context: context,
        builder: (context) =>
            AlertDialog(
              content: SizedBox(
                width: 300,
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Block @${widget.username}?",style: const TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(height: 15,),
                    Text("@${widget.username} will no longer be able to follow or message you,"
                        "and you will not see notifications from @${widget.username}"),
                    Row(
                      children: [
                        const Expanded(child: SizedBox.shrink()),
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                              color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await auth.block(
                              widget.username,
                              isWantedUserFollowed!,
                              isFollowingMe!,
                              success: (res){
                                setState(() {
                                  updateUserFeeds();
                                  isWantedUserBlocked = true;
                                  followers = isWantedUserFollowed!? followers - 1 : followers;
                                  isWantedUserFollowed = false;
                                  if(context.mounted){
                                    Navigator.pop(context);
                                    Toast.showToast(context, "You blocked @${widget.username}.");
                                  }
                                });
                              },
                              error: (res){
                                if(context.mounted){
                                  Toast.showToast(context, "Action failed. Please try again.");
                                }
                              }
                            );
                          },
                          child: Text("Block",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
    );
  }

  void unblockUser() async {
    showDialog(context: context,
        builder: (context) =>
            AlertDialog(
              content: SizedBox(
                width: 300,
                height: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Unblock @${widget.username}?",style: const TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(height: 15,),
                    const Text("They will be able to follow you and view your posts"),
                    Row(
                      children: [
                        const Expanded(child: SizedBox.shrink()),
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await auth.unblock(
                                widget.username,
                              success: (res){
                                setState(() {
                                  isWantedUserBlocked = false;
                                  updateUserFeeds();
                                  if(context.mounted){
                                    Navigator.pop(context);
                                    Toast.showToast(context, "You unblocked @${widget.username}.");
                                  }
                                });
                              },
                              error: (res){
                                if(context.mounted){
                                  Toast.showToast(context, "Action failed. Please try again.");
                                }
                              }
                            );
                          },
                          child: Text("Unblock",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
    );
  }


  @override
  void initState()  {
    auth = Auth.getInstance(context);
    FeedProvider feedProvider = FeedProvider.getInstance(context);
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if(!tabController.indexIsChanging){
        int index = tabController.index;
        onTapBarClick(index, 100);
      }
    });

    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const BlockingLoadingPage():
    Scaffold(
      extendBodyBehindAppBar: true,
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification){
          scroll.value = scrollController.position.pixels;
          return true;
        },
        child: RefreshIndicator(
          notificationPredicate: (notification){
            return notification.depth == 2;
          },
          onRefresh: () async {
            setState(() {
              scroll.value = 0;
              getData();
            });
          },
          child: Stack(
            children: [
              NestedScrollView(
                controller: scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    ValueListenableBuilder(
                      valueListenable: scroll,
                      builder: (context,value,_) {
                        return SliverAppBar(
                          pinned: true,
                          expandedHeight: 130,
                          title: Visibility(
                            visible: value > showNamePosition,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                  style: const TextStyle(
                                      fontSize: 23,
                                      color: Colors.white
                                  ),
                                  maxLines: 1,
                                ),
                                Visibility(
                                  visible: widget.isCurrUser
                                      || (isCurrUser != null && isCurrUser!)
                                      || isCurrUserBlocked != null && !isCurrUserBlocked!,
                                  child: Text(prevTabIndex == 1?
                                  "${widget.isCurrUser? auth.getCurrentUser()!.numOfLikes : numOfLikes} Likes" :
                                  "${widget.isCurrUser? auth.getCurrentUser()!.numOfPosts : numOfPosts} Posts",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          leading: ProfileAppBarIcon(
                            toolTip: 'Navigate Up',
                            icon: Icons.arrow_back,
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),
                          leadingWidth: 60,
                          actions: (value > showNamePosition
                              && (!widget.isCurrUser && !isCurrUser!)
                              && (isWantedUserFollowed != null && !isWantedUserFollowed!)
                              && (isWantedUserBlocked != null && !isWantedUserBlocked!)
                              && (isCurrUserBlocked != null && !isCurrUserBlocked!))?
                          <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ProfileInteract(
                                avatarIsVisible: false,
                                avatarImageUrl: avatarImageUrl,
                                isCurrUser: widget.isCurrUser || (isCurrUser != null && isCurrUser!),
                                isHeader: true,
                                onTapEditProfile: onEditProfileClick,
                                onTapFollow: followUser,
                                onTapUnfollow: unfollowUser,
                                isWantedUserFollowed: isWantedUserFollowed,
                                isWantedUserBlocked: isWantedUserBlocked,
                              ),
                            ),
                          ] :
                          <Widget>[
                            Visibility(
                              visible: widget.isCurrUser || (isCurrUser != null && isCurrUser!) || (isCurrUserBlocked != null && !isCurrUserBlocked!),
                              child: ProfileAppBarIcon(
                                icon: Icons.search,
                                onPressed: (){},
                                toolTip: 'Search',
                              ),
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
                                      onTap: unmuteUser,
                                      child: const Text("Unmute"),
                                    ): PopupMenuItem(
                                      onTap: muteUser,
                                      child: const Text("Mute"),
                                    ),
                                    isWantedUserBlocked != null && isWantedUserBlocked!?
                                    PopupMenuItem(
                                      onTap: unblockUser,
                                      child: const Text("Unblock"),
                                    ):
                                    PopupMenuItem(
                                      onTap: blockUser,
                                      child: const Text("Block"),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                          flexibleSpace: value > collapsePosition ?
                          Stack(
                            fit: StackFit.expand,
                            children: [
                              bannerImageUrl == "" ?
                              Container(color: Colors.blue,) :
                              Image.network(bannerImageUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter,
                              ),
                              Positioned(
                                top: 160,
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 2,
                                    sigmaY: 2,
                                  ),
                                  child: Container(),
                                ),
                              ),
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 0.5),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                                builder: (_,value, __) {
                                  return Container(
                                    color: Colors.black.withOpacity(value),
                                  );
                                },
                              )
                            ],
                          ) :
                          Stack(
                            children: [
                              ProfileBanner(
                                  bannerImageUrl: bannerImageUrl,
                                  onTap:  () async {
                                    if(bannerImageUrl != ""){
                                      var res = await Navigator.push(context,
                                          MaterialPageRoute(builder: (context) =>
                                              ProfileImageView(
                                                isCurrUser: widget.isCurrUser || (isCurrUser != null && isCurrUser!),
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
                                          getData();
                                          scrollController.animateTo(
                                              0,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeIn
                                          );
                                          scroll.value = 0;
                                        });
                                      }
                                    }else if(widget.isCurrUser || (isCurrUser != null && isCurrUser!)){
                                      onEditProfileClick();
                                    }
                                  },
                                ),
                              Positioned(
                                top: 160,
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: value * (2/collapsePosition),
                                    sigmaY: value * (2/collapsePosition),
                                  ),
                                  child: Container(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: scroll,
                              builder: (context,value,_) {
                                return widget.isCurrUser || (isCurrUser != null && isCurrUser!)
                                    || (isCurrUserBlocked != null && !isCurrUserBlocked!) ? ProfileInteract(
                                  avatarIsVisible: value > collapsePosition,
                                  isHeader: false,
                                  avatarImageUrl: avatarImageUrl,
                                  isCurrUser: widget.isCurrUser || (isCurrUser != null && isCurrUser!),
                                  isWantedUserFollowed : isWantedUserFollowed,
                                  isWantedUserBlocked : isWantedUserBlocked,
                                  onTapEditProfile: onEditProfileClick,
                                  onTapDM: () async {
                                    var res = await Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
                                      "user" : User(
                                          id: username ,
                                          name: name ,
                                          iconLink: avatarImageUrl,
                                          mongoID: mongoID,
                                          isFollowed: isWantedUserFollowed,
                                          isBlocked: false,
                                        isFollowingMe: isFollowingMe,
                                      )
                                    }) as Map;
                                    setState(() {
                                      User u = res["user"];
                                      isWantedUserBlocked = u.isBlocked;
                                      scrollController.animateTo(
                                          0,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeIn
                                      );
                                      scroll.value = 0;
                                    });
                                  },
                                  onTapFollow: followUser,
                                  onTapUnfollow: unfollowUser,
                                  onTapUnblock: unblockUser,
                                ) :
                                Row(
                                  children: [
                                    ValueListenableBuilder(
                                        valueListenable: scroll,
                                        builder: (context , value, _) {
                                          return Visibility(
                                            visible: isCurrUserBlocked != null && isCurrUserBlocked! && value > collapsePosition,
                                            child: ProfileAvatar(
                                              avatarImageUrl: avatarImageUrl,
                                              avatarPadding: const EdgeInsets.fromLTRB(13,0,0,5),
                                              avatarRadius: 20,
                                              onTap: onProfileAvatarClick,
                                            ),
                                          );
                                        }
                                    ),
                                    const SizedBox(height: 50,)
                                  ],
                                );
                              }
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold
                              ),
                              maxLines: 2,
                            ),
                            MainText(text: "@${widget.username}", color:Colors.grey ,),
                            bio == "" || (isCurrUserBlocked != null && isCurrUserBlocked!)?
                            const Text("") :
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0,10,0,0),
                              child: SizedBox(
                                  height: 80,
                                  child: MainText(text: bio)
                              ),
                            ),
                            const SizedBox(height: 20,),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 15,color: Colors.grey,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: MainText(text: location,color: Colors.grey,),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10,),
                                Row(
                                  children: [
                                    const Icon(Icons.cake, size: 15,color: Colors.grey,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: MainText(
                                        text: "Born ${DateFormat.yMMMMd('en_US').format(birthDate )}",
                                        color: Colors.grey,
                                      ),
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
                                    const Icon(Icons.date_range, size: 15,color: Colors.grey,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: MainText(
                                        text: "Joined ${DateFormat.yMMMMd('en_US').format(joinedDate)}",
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10,),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.link, size: 15,color: Colors.grey,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: MainText(text: website, color: Colors.grey,), //TODO: change later (detect urls)
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Visibility(
                              visible: widget.isCurrUser || (isCurrUser != null && isCurrUser!)
                                  || ((isWantedUserBlocked != null && !isWantedUserBlocked!)
                                  && (isCurrUserBlocked != null && !isCurrUserBlocked!)),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      Navigator.pushNamed(context, UserListViewPage.pageRoute,
                                        arguments: {
                                          "pageTitle": "Following",
                                          "tweetID" : null,
                                          "userID" : username,
                                          "providerFunction": ProviderFunction.GET_USER_FOLLOWINGS
                                        }
                                      );
                                    },
                                    splashFactory: NoSplash.splashFactory,
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.isCurrUser?
                                          "${auth.getCurrentUser()!.following}" : "$following",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const MainText(text: " Following",color: Colors.grey,),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10,),
                                  InkWell(
                                    onTap: (){
                                      Navigator.pushNamed(context, UserListViewPage.pageRoute,
                                          arguments: {
                                            "pageTitle": "Followers",
                                            "tweetID" : null,
                                            "userID" : username,
                                            "providerFunction": ProviderFunction.GET_USER_FOLLOWERS
                                          }
                                      );
                                    },
                                    splashFactory: NoSplash.splashFactory,
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.isCurrUser?
                                          "${auth.getCurrentUser()!.followers}" : "$followers",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const MainText(text: " Followers", color: Colors.grey,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20,),
                          ],
                        ),
                      )
                    ),
                    SliverVisibility(
                      visible: widget.isCurrUser || (isCurrUser != null && isCurrUser!)
                              || ((isWantedUserBlocked != null && !isWantedUserBlocked!)
                              && (isCurrUserBlocked != null && !isCurrUserBlocked!)),
                      sliver: SliverPersistentHeader(delegate: _SliverAppBarDelegate(
                          Container(
                            color: ThemeProvider.getInstance(context).isDark() ? Colors.black : Colors.white,
                            child: ProfileTabBar(
                              tabController: tabController,
                              onTap: (index){
                                  onTapBarClick(index,10);
                                },
                            ),
                          )
                        ),
                        pinned: true,
                      ),
                    )
                  ];
                },
                body: widget.isCurrUser || (isCurrUser != null && isCurrUser!)
                    || (isWantedUserBlocked != null && !isWantedUserBlocked!
                        && isCurrUserBlocked != null && !isCurrUserBlocked!)?
                TabBarView(
                  controller: tabController,
                  children: [
                    BetterFeed(
                      removeController: true,
                      providerFunction: ProviderFunction.PROFILE_PAGE_TWEETS,
                      providerResultType: ProviderResultType.TWEET_RESULT,
                      feedController: postsFeedController,
                      userId: widget.username,
                      userName: name,
                      removeRefreshIndicator: true,
                    ),
                    BetterFeed(
                      removeController: true,
                      providerFunction: ProviderFunction.PROFILE_PAGE_LIKES,
                      providerResultType: ProviderResultType.TWEET_RESULT,
                      feedController: likesFeedController,
                      userId: widget.username,
                      userName: name,
                      removeRefreshIndicator: true,
                    ),
                  ],
                ) :
                (isCurrUserBlocked != null && isCurrUserBlocked!) ?
                    Column(
                      children: [
                        const Divider(thickness: 1,height: 1,),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text("You are blocked from following @${widget.username} "
                              "and viewing @${widget.username} posts."),
                        ),
                        const Divider(thickness: 1,height: 1,),
                      ],
                    ) :
                    Container(
                      height: 300,
                      color: Colors.blueGrey[900],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Divider(thickness: 1,height: 1,),
                          const SizedBox(height: 50,),
                          Text(
                            "@${widget.username} is blocked",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          )
                        ],
                      ),
                    )
              ),
              ValueListenableBuilder(
                valueListenable: scroll,
                builder: (context,value,_) {
                  return Visibility(
                    visible: value <= collapsePosition,
                    child: ProfileAvatar(
                      avatarImageUrl: avatarImageUrl,
                      avatarPadding: EdgeInsets.fromLTRB(8 + 0.2 * value, 122 - 0.46 * value, 0, 0),
                      avatarRadius: value < collapsePosition? avatarRadius - 0.2 * value : 20,
                      onTap: onProfileAvatarClick,
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FeedHomeTab().getFloatingActionButton(context),
    );
  }
}


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Container _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 39;

  @override
  double get maxExtent => 39;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
