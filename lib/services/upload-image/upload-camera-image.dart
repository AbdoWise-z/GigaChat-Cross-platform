
import 'dart:io';
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();

Future getImageFromCamera(bool isBannerImage) async {
  final pickedImage = await picker.pickImage(
    source: ImageSource.camera,
    maxHeight: isBannerImage? 160 : double.infinity,
  );
  if(pickedImage != null){
    return File(pickedImage.path);
  }else{
    //user canceled
    return File("");
  }
}