import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';
import 'package:gigachat/services/input-validations.dart';


class PasswordFormField extends StatefulWidget {
  void Function(String) onChanged;
  String label;
  String? Function(String?)? validator;
  bool? hideBorder;
  GlobalKey<FormFieldState>? passwordKey;
  PasswordFormField({
    super.key,
    required this.onChanged,
    required this.label,
    this.validator,
    this.hideBorder,
    this.passwordKey
  })
  {
    validator ??= InputValidations.isValidPassword;
    hideBorder ??= false;
  }

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {

  late bool passwordVisible;
  late String password;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
    password = "";
  }
  @override
  Widget build(BuildContext context) {

    bool valid = password.isNotEmpty && widget.validator!(password) == null;

    IconData passwordState =
    passwordVisible ?
    Icons.visibility_outlined :
    Icons.visibility_off_outlined;

    return TextFormField(
      key: widget.passwordKey,
      onChanged: (value) async {
        await Future.delayed(const Duration(milliseconds: 50));
        password = value;
        setState(() {
          widget.onChanged(value);
        });
      },
      obscureText: ! passwordVisible,
      autovalidateMode: widget.hideBorder! ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
      validator: (value){
        return value == null || value.isEmpty ? null : widget.validator!(value);
      },

      decoration: InputDecoration(
        label: Text(widget.label),
        border: const OutlineInputBorder(),
        suffixIcon:
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // hide and show password
            SizedBox(
              width:50,
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      passwordVisible = ! passwordVisible;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        return Colors.transparent;
                      },
                    ),
                    elevation: MaterialStateProperty.all(0),
                    iconColor: MaterialStateProperty.all(ThemeProvider.getInstance(context).getTheme.textTheme.labelSmall!.color)
                  ),
                  child: Icon(passwordState)
              ),
            ),

            // verification Icon
            Visibility(
              visible: valid,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.check_circle_rounded,color: Colors.green),
              ),
            )
          ],
        ),
      ),
    );
  }
}
