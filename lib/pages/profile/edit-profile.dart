
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../services/upload-image/upload-camera-image.dart';
import '../../services/upload-image/upload-local-image.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key,
    required this.avatarImageUrl, required this.bannerImageUrl,
    required this.name, required this.bio, required this.website,
    required this.birthDate}) : super(key: key);

  final String avatarImageUrl;
  final String bannerImageUrl;
  final String name;
  final String bio;
  final String website;
  final DateTime birthDate;



  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  TextEditingController inputName = TextEditingController();
  TextEditingController inputBio = TextEditingController();
  TextEditingController inputWebsite = TextEditingController();
  TextEditingController inputBirthDate = TextEditingController();

  String newBannerImageUrl = "";
  String newAvatarImageUrl = "";
  File selectedAvatar = File("");
  File selectedBanner = File("");

  FocusNode dateFocusNode = FocusNode();
  DateTime nonFormattedDate = DateTime.now();

  bool failed = false;
  bool bannerChanged = false;
  bool avatarChanged = false;
  bool bannerDeleted = false;

  void editImage(bool isProfileAvatar){
    File selectedImage;
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(55, 325, 55, 325),
      items: isProfileAvatar || newBannerImageUrl == "" ? <PopupMenuEntry>[
        PopupMenuItem(
          child: const Text("Take photo"),
          onTap: () async {
            selectedImage = await getImageFromCamera(!isProfileAvatar);
            if(selectedImage.path.isNotEmpty){
              setState(() {
                isProfileAvatar ? avatarChanged = true : bannerChanged = true;
                isProfileAvatar ? selectedAvatar = selectedImage : selectedBanner = selectedImage;
              });
            }
          },
        ),
        PopupMenuItem(
            onTap: () async {
              selectedImage = await getImageFromGallery(!isProfileAvatar);
              if(selectedImage.path.isNotEmpty){
                setState(() {
                  isProfileAvatar ? avatarChanged = true : bannerChanged = true;
                  isProfileAvatar ? selectedAvatar = selectedImage : selectedBanner = selectedImage;
                });
              }
            },
            child: const Text("Choose existing photo              ")
        ),
      ] : <PopupMenuEntry>[
        PopupMenuItem(
          child: const Text("Take photo"),
          onTap: () async {
            selectedImage = await getImageFromCamera(!isProfileAvatar);
            if(selectedImage.path.isNotEmpty){
              setState(() {
                bannerChanged = true;
                selectedBanner = selectedImage;
              });
            }
          },
        ),
        PopupMenuItem(
            onTap: () async {
              selectedImage = await getImageFromGallery(!isProfileAvatar);
              if(selectedImage.path.isNotEmpty){
                setState(() {
                  bannerChanged = true;
                  selectedBanner = selectedImage;
                });
              }
            },
            child: const Text("Choose existing photo              ")
        ),
        PopupMenuItem(
          onTap: () {
            setState(() {
              newBannerImageUrl = "";
              bannerDeleted = true;
            });
          },
          child: Text("Remove header"),
        )
      ],

    );
}

  void updateInfo()async{
    Auth auth = Auth.getInstance(context);
    bool infoChanged = widget.name != inputName.text
        || widget.website != inputWebsite.text
        || widget.birthDate != nonFormattedDate
        || widget.bio != inputBio.text;
    if(DateTime.now().difference(nonFormattedDate).inDays < 18 * 365){
      Toast.showToast(context, "Failed to update profile");
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20,),
              Text("Updating profile"),
            ],
          ),
        )
    );
    if(bannerChanged){
      print("banner request here");
      await auth.setUserBannerImage(
        selectedBanner,
        success: (res){
          newBannerImageUrl = res.data!;
        },
        error: (res){
          failed = true;
        }
      );
    }
    if(avatarChanged){
      print("avatar request here");
      await auth.setUserProfileImage(
        selectedAvatar,
        success: (res){
          newAvatarImageUrl = res.data!;
        },
        error: (res){
          failed = true;
        }
      );
    }
    if(infoChanged){
      await auth.setUserInfo(inputName.text, inputBio.text,
        inputWebsite.text, "Cairo, Egypt", nonFormattedDate,
        error: (res){
          failed = true;
        }
      );
    }
    if(bannerDeleted){
      await auth.deleteUserBanner(
        success: (res){
          newBannerImageUrl = "";
        },
        error: (res){
          failed = true;
        }
      );
    }
    if(context.mounted){
      Navigator.pop(context); //to pop the alert dialog
      if(failed) {
        Toast.showToast(context, "Failed to update profile");
      }
      else{
        Navigator.pop(context,{
          "name" : inputName.text,
          "bio": inputBio.text,
          "website" : inputWebsite.text,
          "birthDate" : nonFormattedDate,
          "bannerImageUrl" : newBannerImageUrl,
          "avatarImageUrl" : newAvatarImageUrl,
        });
      }
    }
  }

  @override
  void initState() {
    inputName.text = widget.name;
    inputBirthDate.text = DateFormat.yMMMMd().format(widget.birthDate);
    inputWebsite.text = widget.website;
    inputBio.text = widget.bio;
    newBannerImageUrl = widget.bannerImageUrl;
    newAvatarImageUrl = widget.avatarImageUrl;
    nonFormattedDate = widget.birthDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit profile",style: TextStyle(fontSize: 20),),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: GestureDetector(
                onTap: updateInfo,
                child: Text("Save",style:
                TextStyle(
                  color: ThemeProvider.getInstance(context).isDark()? Colors.white : Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
                ),
              ),
            ),
          )
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1,),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: () => editImage(false),
                  child: Stack(
                    children: [
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
                        child: Container(
                          color: Colors.blue,
                          height: 160,
                          width: double.infinity,
                          child: bannerChanged? Image.file(
                            selectedBanner,
                            fit: BoxFit.cover,
                          ) :
                          newBannerImageUrl == ""? null :
                          Image.network(
                            newBannerImageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(180,70,0,0),
                        child: Icon(Icons.add_a_photo_outlined,color: Colors.white,size: 30,),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Theme(
                    data: ThemeProvider.getInstance(context).isDark() ? ThemeData.dark() : ThemeData.light(),  //to cancel the theme effects
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40,),
                        Text("Name",style: TextStyle(color: Colors.grey[700]),),
                        TextFormField(
                          controller: inputName,
                          autofocus: true,
                          onTap: (){
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 15,),
                        Text("Bio",style: TextStyle(color: Colors.grey[700]),),
                        TextFormField(
                          controller: inputBio,
                          minLines: 2,
                          maxLines: 3,
                          maxLength: 160,
                          onTap: (){
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 15,),
                        Text("Location",style: TextStyle(color: Colors.grey[700]),),
                        TextFormField(
                          readOnly: true,
                          initialValue: "Cairo, Egypt",
                          onTap: (){
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 15,),
                        Text("Website",style: TextStyle(color: Colors.grey[700]),),
                        TextFormField(
                          controller: inputWebsite,
                          onTap: (){
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 15,),
                        Text("Birth date",style: TextStyle(color: Colors.grey[700]),),
                        TextFormField(
                          controller: inputBirthDate,
                          focusNode: dateFocusNode,
                          readOnly: true,
                          onTap: (){
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 150,),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10,125,0,0),
              child: InkWell(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,// fk it
                onTap: () => editImage(true),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: ThemeProvider.getInstance(context).isDark()? Colors.black : Colors.white,
                              width: 3)
                      ),
                      child: ClipOval(
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
                          child: avatarChanged? CircleAvatar(
                            radius: 35,
                            backgroundImage: FileImage(selectedAvatar),
                          ) :
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(newAvatarImageUrl),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(22,22,0,0),
                      child: Icon(Icons.add_a_photo_outlined,color: Colors.white,size: 30,),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Visibility(
          visible: dateFocusNode.hasFocus,  //visible when date text_field is focused
          child: SizedBox(
            height: 100,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: DateTime.now(),
              maximumDate: DateTime.now(),
              onDateTimeChanged: (input){
                setState(() {
                  inputBirthDate.text = DateFormat.yMMMMd('en_US').format(input);
                  nonFormattedDate = input;
                });
              },
            ),
          )
      ),
    );
  }
}
