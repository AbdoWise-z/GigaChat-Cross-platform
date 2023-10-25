import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Widget renderVerificationIcon(String? password)
{
    if (password == null || password.isEmpty)
    {
        return const SizedBox();
    }
    else
    {
        print("Password Passed !! $password");
        // TODO: make password verifications
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.check_circle_rounded,color: Colors.green),
        );
    }
}