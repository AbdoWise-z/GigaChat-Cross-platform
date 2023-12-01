
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();

Future getImageFromCamera(bool isBannerImage) async {
  final pickedImage = await picker.pickImage(
    source: ImageSource.camera,
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