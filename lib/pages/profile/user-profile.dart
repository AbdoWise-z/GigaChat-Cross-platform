import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);
  static const pageRoute = '/user-profile';

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  ScrollController scrollController = ScrollController();
  bool collapsed = false;
  bool showName = false;
  double avatarRadius = 35;
  EdgeInsetsGeometry avatarPadding = const EdgeInsets.fromLTRB(8, 122, 0, 0);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: showName? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Osama Saleh", //TODO: nickname
                style: TextStyle(
                  fontSize: 23,
                ),
              ),
              Text("2 Posts"), //TODO: num of posts
            ],
          ) : null,
          backgroundColor: Colors.transparent,
          leading: const ProfileAppBarIcon(icon: Icons.arrow_back,),
          leadingWidth: 40,
          actions: const [
            ProfileAppBarIcon(icon: Icons.search),
            ProfileAppBarIcon(icon: Icons.more_vert),
          ],
          flexibleSpace: collapsed? FlexibleSpaceBar(
            background: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
              child: Image.network("https://dotesports.com/wp-content"
                  "/uploads/2022/11/01152943/Character-Teaser-Nahida-Happy-Birthday-G"
                  "enshin-Impact_-Character-Teaser-Nahida-Happy-Bir"
                  "thday-Genshin-Impact-2022-11-1-94214.498-1080p-streamshot.png", //TODO: banner image
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ) : null
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
        child: SingleChildScrollView(
          controller: scrollController,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image.network("https://dotesports.com/wp-content"
                        "/uploads/2022/11/01152943/Character-Teaser-Nahida-Happy-Birthday-G"
                        "enshin-Impact_-Character-Teaser-Nahida-Happy-Bir"
                        "thday-Genshin-Impact-2022-11-1-94214.498-1080p-streamshot.png", //TODO: banner image
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
                            OutlinedButton(
                              onPressed: (){},
                              style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )
                              ),
                              child: const Text("Edit profile",style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
                        Text(
                          "Osama Saleh",  //TODO: Nickname
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text("@Oasadasda"), //TODO: username
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 15,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text("Cairo, Egypt"),
                                ), //TODO: location
                              ],
                            ),
                            SizedBox(width: 10,),
                            Row(
                              children: [
                                Icon(Icons.cake, size: 15,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text("Born August 25, 2002"),
                                ), //TODO: birthDate
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Icon(Icons.date_range, size: 15,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Text("Joined August 25, 2002"),
                            ), //TODO: joinedDate
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "122 ", //TODO: followingNum
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Following"),
                              ],
                            ),
                            SizedBox(width: 10,),
                            Row(
                              children: [
                                Text(
                                  "0 ", //TODO: followersNum
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Followers"),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Container(height: 1000,color: Colors.red,) //TODO: user feed
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
                  radius: avatarRadius,
                  backgroundImage: NetworkImage("https://dotesports.com/wp-content"
                      "/uploads/2022/11/01152943/Character-Teaser-Nahida-Happy-Birthday-G"
                      "enshin-Impact_-Character-Teaser-Nahida-Happy-Bir"
                      "thday-Genshin-Impact-2022-11-1-94214.498-1080p-streamshot.png",), //TODO: user profile image
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfileAppBarIcon extends StatelessWidget {
  final IconData icon;
  const ProfileAppBarIcon({Key? key,required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
    );
  }
}



