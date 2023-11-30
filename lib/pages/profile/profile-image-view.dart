import 'package:flutter/material.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:gigachat/services/upload-image/upload-camera-image.dart';
import 'package:gigachat/services/upload-image/upload-local-image.dart';
import 'dart:io';

class ProfileImageView extends StatelessWidget {
  final bool isProfileAvatar;
  final String imageUrl;
  const ProfileImageView({Key? key,required this.isProfileAvatar,required this.imageUrl}) : super(key: key);

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
              }: (){
                //TODO: navigate to edit profile
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
        ],
      ),
    );
  }


}
