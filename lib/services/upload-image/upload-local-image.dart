
import 'dart:io';
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();

Future getImageFromGallery() async {
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
  if(pickedImage != null){
    return File(pickedImage.path);
  }else{
    //user canceled
    return File("");
  }
}