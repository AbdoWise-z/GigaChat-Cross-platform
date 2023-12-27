import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';

/// Bottom sheet for authentication pages
/// Have 2 buttons
///     * left button (usually for returning back)
///     * right button (usually for navigating to next page)
class AuthFooter extends StatelessWidget {
  bool disableRightButton;
  bool? showLeftButton;
  String leftButtonLabel;
  String rightButtonLabel;
  Function() onLeftButtonPressed;
  Function() onRightButtonPressed;

  Key? rightButtonKey;
  Key? leftButtonKey;

  AuthFooter({
    super.key,
    required this.disableRightButton,
    required this.showLeftButton,
    required this.leftButtonLabel,
    required this.rightButtonLabel,
    required this.onLeftButtonPressed,
    required this.onRightButtonPressed,
    this.leftButtonKey,
    this.rightButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Column(children: [
        const Divider(
          thickness: 0.5,
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Visibility(
                visible: showLeftButton ?? false,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: onLeftButtonPressed,
                    child: Text(
                      leftButtonLabel,
                      style: TextStyle(
                        color: ThemeProvider.getInstance(context)
                            .getTheme
                            .textTheme
                            .labelSmall!
                            .color,
                      ),
                    )),
              ),

              const Expanded(child: SizedBox()),

              ElevatedButton(
                key: rightButtonKey,
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: disableRightButton ? null : onRightButtonPressed,
                child: Text(
                  rightButtonLabel,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
