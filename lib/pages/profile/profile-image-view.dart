import 'package:flutter/material.dart';
import 'package:gigachat/pages/profile/edit-profile.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:gigachat/services/upload-image/upload-camera-image.dart';
import 'package:gigachat/services/upload-image/upload-local-image.dart';
import 'dart:io';

/// This is the page where users can see theirs and others profile image & banner
/// Currently logged in user can edit his profile image & banner
class ProfileImageView extends StatelessWidget {
  final bool isProfileAvatar;
  final String imageUrl;
  final bool isCurrUser;
  String? name;
  String? avatarImageUrl;
  String? bio;
  String? website;
  DateTime? birthDate;

   ProfileImageView({Key? key,
    required this.isProfileAvatar,
    required this.imageUrl,
     this.name,
     this.avatarImageUrl,
     this.bio,
     this.website,
     this.birthDate, required this.isCurrUser
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    File selectedImage;
    Auth auth = Auth.getInstance(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              minScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(
                imageUrl,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Visibility(
              visible: isCurrUser,
              child: OutlinedButton(
                onPressed: isProfileAvatar? (){
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(55, 325, 55, 325),
                    items: [
                      PopupMenuItem(
                        child: const Text("Take photo"),
                        onTap: () async {
                          selectedImage = await getImageFromCamera(!isProfileAvatar);
                          if(selectedImage.path.isNotEmpty){
                            await auth.setUserProfileImage(
                              selectedImage,
                              success: (str){
                                print("Image Uploaded Successfully !");
                              },
                              error: (str){
                                Toast.showToast(context, "Failed to upload image");
                              }
                            );
                          }
                          if(!context.mounted) return;
                          Navigator.pop(context,isProfileAvatar? auth.getCurrentUser()!.iconLink : auth.getCurrentUser()!.bannerLink);
                        },
                      ),
                      PopupMenuItem(
                          onTap: () async {
                            selectedImage = await getImageFromGallery(!isProfileAvatar);
                            if(selectedImage.path.isNotEmpty){
                              await auth.setUserProfileImage(
                                  selectedImage,
                                  success: (str){
                                    print("Image Uploaded Successfully !");
                                  },
                                  error: (str){
                                    Toast.showToast(context, "Failed to upload image");
                                  }
                              );
                            }
                            if(!context.mounted) return;
                            Navigator.pop(context,isProfileAvatar? auth.getCurrentUser()!.iconLink : auth.getCurrentUser()!.bannerLink);
                          },
                          child: const Text("Choose existing photo              ")
                      ),
                    ],
                  );
                }: () async {
                 var res = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          EditProfile(
                            avatarImageUrl: avatarImageUrl!,
                            bannerImageUrl: imageUrl,
                            name: name!,
                            bio: bio!,
                            website: website!,
                            birthDate: birthDate!,
                        )
                      )
                  );
                 if(res != null && context.mounted){
                   Navigator.pop(context,
                     {
                       "name" : res["name"],
                       "bio" : res["bio"],
                       "website" : res["website"],
                       "birthDate" : res["birthDate"],
                       "bannerImageUrl" : res["bannerImageUrl"],
                       "avatarImageUrl" : res["avatarImageUrl"]
                     }
                   );
                 }
                } ,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: const BorderSide(
                    color: Colors.white,
                  )
                ),
                child: const Text("Edit",style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
