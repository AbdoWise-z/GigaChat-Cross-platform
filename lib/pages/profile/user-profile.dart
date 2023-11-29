
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:intl/intl.dart';
import '../../api/user-class.dart';

class UserProfile extends StatefulWidget {
  String username;
  bool isCurrUser;
  UserProfile({Key? key, required this.username, required this.isCurrUser}) : super(key: key);

  static const pageRoute = '/user-profile';

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with TickerProviderStateMixin {

  //user details
  late String name;
  late String username;
  late String? avatarImageUrl;
  late String? bannerImageUrl;  //can be null
  String location = "Cairo, Egypt";
  late DateTime? birthDate;
  late DateTime? joinedDate;
  late int following;
  late int followers;


  //page details
  bool loading = true;
  ScrollController scrollController = ScrollController();
  TabController? tabController;
  bool collapsed = false;
  bool showName = false;
  double avatarRadius = 35;
  EdgeInsetsGeometry avatarPadding = const EdgeInsets.fromLTRB(8, 122, 0, 0);

  void getData() async {
    setState(() {
      loading = true;
    });
    var res = await Account.apiUserProfile(widget.username);
    User? u = res.data;
    if(u != null){
      name = u.name;
      username = u.id;
      avatarImageUrl = u.iconLink;
      bannerImageUrl = u.bannerLink;
      birthDate = u.birthDate;
      joinedDate = u.joinedDate;
      following = u.following;
      followers = u.followers;
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState()  {
    tabController = TabController(length: 4, vsync: this);
    getData();
    super.initState();
  }


  //TODO: banner image alignment
  //TODO: search button
  //TODO: profile avatar page
  //TODO: banner image page
  //TODO: get tweets

  @override
  Widget build(BuildContext context) {

    return loading? const BlockingLoadingPage(): Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: showName? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, //TODO: nickname
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
            icon: Icons.arrow_back,
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          leadingWidth: 60,
          actions:  showName && !widget.isCurrUser?
          [
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
          ]:
          [
            ProfileAppBarIcon(
                icon: Icons.search,
              onPressed: (){
                  //TODO:
              },
            ),
            ProfileAppBarIcon(
                icon: Icons.more_vert,
              onPressed: (){
                  //TODO:
              },
            ),
          ],
          flexibleSpace: collapsed? FlexibleSpaceBar(
            background: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
              child: Container(
                color: Colors.blue,
                child: Image.network("https://www.ggrecon."
                    "com/media/l5skm20t/who-is-nahida-genshin-impact.jpg?mode=crop&width=682&quality=80&format=webp", //TODO: banner image
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ) : null,
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification){
          setState(() {
            double pos = scrollController.position.pixels;
            collapsed = pos > 80 ? true : false;
            showName = pos > 162 ? true : false;
            avatarRadius = pos < 155? 35 - 0.2 * pos : 20;
            avatarPadding = pos < 155? EdgeInsets.fromLTRB(8 + 0.2 * pos, 122 + 0.46 * pos, 0, 0) :
            const EdgeInsets.fromLTRB(24, 160, 0, 0);
          });
          return true;
        },
        child: RefreshIndicator(
          onRefresh: ()async{

          },
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.blue,
                          child: Image.network("https://www.ggrecon"
                              ".com/media/l5skm20t/who-is-nahida-genshin-impact.jp"
                              "g?mode=crop&width=682&quality=80&format=webp", //TODO: banner image
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: SizedBox()),
                                  Visibility(
                                    visible: !widget.isCurrUser,
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(width: 1,
                                              color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black)
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.mail_outline,
                                            size: 17.5,
                                            color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black,
                                          ),
                                          onPressed: (){

                                          },
                                        ),
                                      ),
                                  ),
                                  const SizedBox(width: 10,),
                                  widget.isCurrUser? OutlinedButton(
                                    onPressed: (){},
                                    style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        )
                                    ),
                                    child: const Text("Edit profile",style: TextStyle(fontWeight: FontWeight.bold),),
                                  ) : FollowButton(
                                    onPressed: (){
                                      //TODO: follow user
                                    },
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                  )
                                ],
                              ),
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text("@$username"),
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
                                        child: Text("Born ${DateFormat.yMMMMd('en_US').format(birthDate?? DateTime.now())}"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  const Icon(Icons.date_range, size: 15,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Text("Joined ${DateFormat.yMMMMd('en_US').format(joinedDate?? DateTime.now())}"),
                                  ),
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
                              Container(
                                height: 2000, //TODO: user feed (change height dynamically every getTweets request)
                                child: TabBarView(
                                  controller: tabController,
                                    children: [
                                      Container(height: 1000,width:200,color: Colors.red,child: Center(child: Text("1"),),),
                                      Container(height: 1000,width:200,color: Colors.red,child: Center(child: Text("2"),),),
                                      Container(height: 1000,width:200,color: Colors.red,child: Center(child: Text("3"),),),
                                      Container(height: 1000,width:200,color: Colors.red,child: Center(child: Text("4"),),),
                                    ]
                                ),
                              )
                            ],
                          ),
                        )

                      ],
                    ),
                    AnimatedContainer(
                      margin: avatarPadding,
                      width: 2 * avatarRadius,
                      height: 2 * avatarRadius,
                      transformAlignment: AlignmentDirectional.bottomCenter,
                      duration: const Duration(milliseconds: 10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: ThemeProvider.getInstance(context).isDark()? Colors.black : Colors.white,
                              width: 3)
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: avatarRadius,
                        backgroundImage: avatarImageUrl == ""? null : NetworkImage(avatarImageUrl!,),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: scrollController.hasClients && scrollController.position.pixels > 295,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10,80,10,10),
                  child: Container(
                    color: ThemeProvider.getInstance(context).isDark() ? Colors.black : Colors.white,
                    width: double.infinity,
                    child: ProfileTabBar(
                      tabController: tabController,
                      onTap: (index){
                        setState(() {
                          scrollController.animateTo(295, duration: const Duration(milliseconds: 10), curve: Curves.easeInOut);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}


class ProfileAppBarIcon extends StatelessWidget {
  final IconData icon;
  final void Function()? onPressed;
  const ProfileAppBarIcon({Key? key,required this.icon,required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 35,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          iconSize: 22,
          icon: Icon(icon),color: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class ProfileTabBar extends StatelessWidget {
  ProfileTabBar({Key? key, this.tabController,this.onTap}) : super(key: key);

  TabController? tabController;
  List<String> tabs = [
    "Posts" , "Replies", "Media", " Likes",
  ];
  void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    return TabBar(
        controller: tabController,
        tabs: tabs.map((e) => Text(e)).toList(),
      onTap: onTap,
      tabAlignment: TabAlignment.fill,
    );
  }
}

class FollowButton extends StatelessWidget {
  FollowButton({Key? key,this.backgroundColor,this.onPressed,this.textColor,this.padding}) : super(key: key);

  void Function()? onPressed;
  Color? textColor;
  Color? backgroundColor;
  EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: backgroundColor,
        padding: padding,
      ),
      child: Text(
        "Follow",
        style: TextStyle(
          color: textColor,
        ),//TODO: change later
      ),
    );
  }
}





