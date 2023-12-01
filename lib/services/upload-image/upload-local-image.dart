
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

final picker = ImagePicker();

Future getImageFromGallery(bool isBannerImage) async {
  final pickedImage = await picker.pickImage(
    source: ImageSource.gallery,
  );
  if(pickedImage != null){

    CroppedFile? croppedFile;

    if(isBannerImage){
        croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 5.0, ratioY: 2.0),
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