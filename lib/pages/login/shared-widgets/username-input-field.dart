
import 'package:flutter/material.dart';
import '../../../base.dart';

Widget UsernameFormField({required Function onChange, String? value, bool? isEnabled})
{
  return TextFormField(
    onChanged: (username){onChange(username);},
    initialValue: value ?? "",
    enabled: isEnabled ?? true,
    decoration: const InputDecoration(
        label:  Text(USERNAME_INPUT_LABEL),
        border: OutlineInputBorder()
    ),
  );
}