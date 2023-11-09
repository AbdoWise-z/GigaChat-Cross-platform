
import 'package:flutter/material.dart';


class TextDataFormField extends StatefulWidget {

  void Function(String) onChange;
  String? Function(String?)? validator;
  String? value;
  bool? isEnabled;
  String? label;

  TextDataFormField({
    super.key,
    required this.onChange,
    this.validator,
    this.value,
    this.isEnabled,
    this.label
  });

  @override
  State<TextDataFormField> createState() => _TextDataFormFieldState();
}

class _TextDataFormFieldState extends State<TextDataFormField> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChange,
      initialValue: widget.value ?? "",
      enabled: widget.isEnabled ?? true,
      validator: widget.validator,
      decoration: InputDecoration(
          label:  Text(widget.label ?? "Phone, email or username"),
          border: const OutlineInputBorder()
      ),
    );
  }
}
