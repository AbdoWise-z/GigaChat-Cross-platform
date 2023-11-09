
import 'package:flutter/material.dart';
import 'package:gigachat/pages/setup-profile/choose-username.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/upload-image.dart';
import '../../providers/theme-provider.dart';
import 'dart:io';

class PickProfilePicture extends StatefulWidget {
  const PickProfilePicture({Key? key}) : super(key: key);

  static const pageRoute = '/setup-profile-picture';

  @override
  State<PickProfilePicture> createState() => _PickProfilePictureState();
}

class _PickProfilePictureState extends State<PickProfilePicture> {
  File selectedImage = File("");

  @override
  Widget build(BuildContext context) {
    bool isButtonDisabled = selectedImage.path == "";
    return Scaffold(
      appBar: AuthAppBar(context,
        leadingIcon: null,
        showDefault: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             const SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pick a profile picture",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Text("Have a favourite selfie? Upload it now.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            UploadImage(
              onImagePicked: (File file){
                setState(() {
                  selectedImage = file;
                });
              },
            ),
          ],
        ),
      ),
      bottomSheet: AuthFooter(
        disableRightButton: isButtonDisabled,
        showLeftButton: true,
        leftButtonLabel: "Skip for now",
        rightButtonLabel: "Next",
        onLeftButtonPressed: (){
          //navigate to username page
          Navigator.pushReplacementNamed(context, ChooseUsername.pageRoute);
        },
        onRightButtonPressed: () async {
          //TODO: request to add image to user
          //navigate to username page
          Navigator.pushReplacementNamed(context, ChooseUsername.pageRoute);
        },
      ),
    );
  }
}
