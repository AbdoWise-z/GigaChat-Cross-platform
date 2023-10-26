
import 'package:flutter/material.dart';
import '../base.dart';

Widget UsernameFormField({
  required Function onChange,
  String? value,
  bool? isEnabled,
  String? label
})
{
  // TODO: email verifications required
  return TextFormField(
    onChanged: (username){onChange(username);},
    initialValue: value ?? "",
    enabled: isEnabled ?? true,
    decoration: InputDecoration(
        label:  Text(label ?? USERNAME_INPUT_LABEL),
        border: const OutlineInputBorder()
    ),
  );
}