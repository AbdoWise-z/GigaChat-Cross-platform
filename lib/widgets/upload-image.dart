
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gigachat/services/upload-image/upload-camera-image.dart';
import 'package:gigachat/services/upload-image/upload-local-image.dart';

bool done = false;

//for drawing the borders of the UPLOAD image widget
class IntermittentCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    double dashWidth = 10, dashSpace = 10;

    canvas.drawArc(const Rect.fromLTWH(0, 0, 20, 20), 3.14, 3.14 / 2, false, paint); //top left corner
    canvas.drawArc(Rect.fromLTWH(size.width - dashSpace - 5, 0, 15, 20), 3 * 3.14 / 2, 3.14 / 2, false, paint); //top right corner
    canvas.drawArc(Rect.fromLTWH(0, size.width - dashSpace - 5, 20, 15), 3.14/2, 3.14/2, false, paint); //bottom left corner
    canvas.drawArc(Rect.fromLTWH(size.width - dashSpace - 5, size.width - dashSpace - 5, 15, 15), 0, 3.14 / 2, false, paint);

    //left side
    double startY = dashWidth + dashSpace - 3;
    while (startY < size.height - 3) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    //bottom side
    double startX = dashWidth + dashSpace - 3;
    while (startX < size.width - 3) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }

    //top side
    startX = size.width - dashSpace - dashWidth - 3;
    canvas.drawArc(const Rect.fromLTWH(0, 0, 20, 20), 3.14, 3.14 / 2, false, paint);
    while (startX > 0) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX -= dashWidth + dashSpace;
    }

    //right side
    startY = size.height - dashSpace - dashWidth - 3;
    while (startY > 3) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class UploadImage extends StatefulWidget {

  //callback function to notify the page that an image has been picked
  final ValueChanged<File> onImagePicked;

  const UploadImage({Key? key,required this.onImagePicked}) : super(key: key);

  @override
  State<UploadImage> createState() => UploadImageState();
}

class UploadImageState extends State<UploadImage> {

  File selectedImage = File("");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashFactory: done? NoSplash.splashFactory : InkSplash.splashFactory,
        onTap: (){
          showMenu(
            context: context,
            position: const RelativeRect.fromLTRB(55, 325, 55, 325),
            items: [
              PopupMenuItem(
                child: const Text("Take photo"),
                onTap: () async {
                  selectedImage = await getImageFromCamera();
                  if(selectedImage.path.isNotEmpty){
                    setState(() {
                      done = true;
                      widget.onImagePicked(selectedImage);
                    });
                  }
                },
              ),
              PopupMenuItem(
                  onTap: () async {
                    selectedImage = await getImageFromGallery();
                    if(selectedImage.path.isNotEmpty){
                      setState(() {
                        done = true;
                        widget.onImagePicked(selectedImage);
                      });
                    }
                  },
                  child: const Text("Choose existing photo              ")
              ),
            ],
          );
        },
        child: done ? CircleAvatar(
          radius: 100,
          backgroundImage: FileImage(selectedImage),
        ):
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: IntermittentCurvedContainer(),
              ),
            ),
            const Column(
              children: [
                Icon(Icons.add_a_photo,color: Colors.blue,size: 75,),
                SizedBox(height: 15,),
                Text("Upload",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
