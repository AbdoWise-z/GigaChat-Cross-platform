
import 'package:flutter/material.dart';
import 'package:gigachat/pages/setup-profile/choose-username.dart';
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
      appBar: AppBar(
        toolbarHeight: 40,
        elevation: 0,
        centerTitle: true,
        title: SizedBox(
          height: 40,
          width: 40,
          child: Image.asset(
            ThemeProvider.getInstance(context).isDark() ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png',
          ),
        ),
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
      bottomSheet: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Divider(thickness: 0.6, height: 1,),
            Padding(
              padding: const EdgeInsets.fromLTRB(10,10,10,0),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: (){
                      //navigate to username page
                      Navigator.pushReplacementNamed(context, ChooseUsername.pageRoute);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      )
                    ),
                    child: const Text("Skip for now"),
                  ),
                  const Expanded(child: SizedBox()),
                  ElevatedButton(
                    onPressed: isButtonDisabled? null : () async {
                      //TODO: request to add image to user
                      //navigate to username page
                      Navigator.pushReplacementNamed(context, ChooseUsername.pageRoute);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          )
                      ),
                    ),
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
