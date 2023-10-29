
import 'package:flutter/material.dart';
import '../base.dart';

Widget TextDataFormField({
  required void Function(String) onChange,
  String? value,
  bool? isEnabled,
  String? label
})
{
  // TODO: email verifications required
  return TextFormField(
    onChanged: onChange,
    initialValue: value ?? "",
    enabled: isEnabled ?? true,
    decoration: InputDecoration(
        label:  Text(label ?? "Phone, email or username"),
        border: const OutlineInputBorder()
    ),
  );
}