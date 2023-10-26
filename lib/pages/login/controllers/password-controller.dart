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
        // TODO: make password verification
        return const SizedBox();
    }
}