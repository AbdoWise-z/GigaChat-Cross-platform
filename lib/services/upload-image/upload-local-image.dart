
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

/// Used to get an image from the gallery of the user

final picker = ImagePicker();

Future getImageFromGallery(bool isBannerImage) async {
  final pickedImage = await picker.pickImage(
    source: ImageSource.gallery,
  );
  if(pickedImage != null){

    CroppedFile? croppedFile;

    if(isBannerImage && Platform.isAndroid){
        croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 5.0, ratioY: 2.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarWidgetColor: Colors.black,
            backgroundColor: Colors.black,
            cropGridColor: Colors.transparent,
            toolbarTitle: "Edit Image",
            activeControlsWidgetColor: Colors.black,
          )
        ]
      );
        if(croppedFile != null){
          return File(croppedFile.path);
        }else {
          return File("");
        }
    }else{
      return File(pickedImage.path);
    }

  }else{
    //user canceled
    return File("");
  }
}