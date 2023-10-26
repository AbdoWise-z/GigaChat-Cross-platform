import 'package:flutter/material.dart';
import '../base.dart';

PreferredSizeWidget LoginAppBar() {
  return AppBar(
    centerTitle: true,
    title: Text(
      APP_NAME.toUpperCase(),
      style: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
