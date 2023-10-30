import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/providers/theme-provider.dart';


class PasswordFormField extends StatefulWidget {
  void Function(String) onChanged;
  String? Function(String?) validator;
  String label;
  PasswordFormField({
    super.key,
    required this.onChanged,
    required this.validator,
    required this.label
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  late void Function(String) onChanged;
  late String? Function(String?) validator;
  late String label;

  late bool passwordVisible;
  late bool verified = false;
  bool valid = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onChanged = widget.onChanged;
    validator = widget.validator;
    label = widget.label;
    passwordVisible = false;
  }
  @override
  Widget build(BuildContext context) {
    IconData passwordState =
    passwordVisible ?
    Icons.visibility_outlined :
    Icons.visibility_off_outlined;

    return TextFormField(
      onChanged: (value){
        setState(() {
          valid = validator(value) == null;
          print(validator(value));
          onChanged(value);
        });
      },
      obscureText: ! passwordVisible,
      autocorrect: false,
      enableSuggestions: false,

      decoration: InputDecoration(
        label: Text(label),
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
