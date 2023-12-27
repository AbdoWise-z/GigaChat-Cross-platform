
import 'package:flutter/material.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/setup-profile/choose-username.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/upload-image.dart';
import 'dart:io';

/// This where user can set a profile image for the first time after registering
class PickProfilePicture extends StatefulWidget {
  const PickProfilePicture({Key? key}) : super(key: key);

  static const pageRoute = '/setup-profile-picture';

  @override
  State<PickProfilePicture> createState() => _PickProfilePictureState();
}

class _PickProfilePictureState extends State<PickProfilePicture> {
  File selectedImage = File("");

  bool _loading = false;
  void _setProfileImage(File img) async {
    setState(() {
      _loading = true;
    });

    Auth auth = Auth.getInstance(context);
    if (auth.getCurrentUser() == null){
      throw "This should never happen ...";
    }

    await auth.setUserProfileImage(
      img,
      success: (res) {
        _loading = false;
        Navigator.pushReplacementNamed(context, ChooseUsername.pageRoute);
      },
      error: (res) {
        print(res.responseBody);
        _loading = false;
        Toast.showToast(context, "API Error ..");
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    bool isButtonDisabled = selectedImage.path.isEmpty;
    return Stack(
      children: [
        Scaffold(
          appBar: AuthAppBar(context,
            leadingIcon: null,
            showDefault: false,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
                child: Padding(
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
                      const SizedBox(height: 50,),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomSheet: AuthFooter(
            disableRightButton: isButtonDisabled,
            showLeftButton: true,
            leftButtonLabel: "Skip for now",
            rightButtonLabel: "Next",
            onRightButtonPressed: () => _setProfileImage(selectedImage),
            onLeftButtonPressed: () async {
              Navigator.pushReplacementNamed(context, ChooseUsername.pageRoute);
            },
          ),
        ),
        Visibility(
          visible: _loading,
          child: const Positioned.fill(child: BlockingLoadingPage()),
        ),
      ],
    );
  }
}
