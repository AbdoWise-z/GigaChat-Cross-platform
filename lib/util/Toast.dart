
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toast{
  FToast fToast;
  Toast(BuildContext context): fToast = FToast() {
    fToast.init(context);
  }
  void showToast(String message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(message),],
      ),
    );


    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}