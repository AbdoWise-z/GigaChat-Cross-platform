import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/blocking-loading-page.dart';
import 'package:gigachat/pages/forget-password/forget-password.dart';
import 'package:gigachat/pages/user-verification/select-verification-method-page.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/services/input-validations.dart';
import 'package:gigachat/util/Toast.dart';
import 'package:gigachat/widgets/auth/auth-app-bar.dart';
import 'package:gigachat/widgets/text-widgets/page-description.dart';
import 'package:gigachat/widgets/auth/auth-footer.dart';
import 'package:gigachat/widgets/text-widgets/page-title.dart';
import 'package:gigachat/widgets/auth/input-fields/username-input-field.dart';

const String CONFIRM_EMAIL_PAGE_DESCRIPTION =
    "Verify your identity by entering the email address associated with your $APP_NAME account.";

class ConfirmEmailPage extends StatefulWidget {
  final String username;

  const ConfirmEmailPage({super.key, required this.username});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  late String email;
  late bool isValidEmail;

  @override
  void initState() {
    super.initState();
    email = "";
    isValidEmail = false;
  }

  bool _loading = false;
  void _getContactMethods() async {
    setState(() {
      _loading = true;
    });

    var methods = await Auth.getInstance(context).getContactMethods(email , (m) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(
          builder: (context) =>
              VerificationMethodPage(
                  methods: m
              ),
        ),
      );
    });

    if (methods == null){
      Toast.showToast(context, "API Error ");
    }

    setState(() {
      _loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const BlockingLoadingPage();
    }

    return Scaffold(
      appBar: AuthAppBar(
        context,
        leadingIcon: IconButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const PageTitle(title: "Confirm your email"),
          const SizedBox(height: 15),
          const PageDescription(description: CONFIRM_EMAIL_PAGE_DESCRIPTION),
          const SizedBox(height: 20),
          TextDataFormField(
            onChange: (value) {
              setState(() {
                email = value;
                isValidEmail = email.isNotEmpty &&
                    InputValidations.isValidEmail(email) == null;
              });
            },
            label: "Email",
          ),
          const Expanded(child: SizedBox()),
          AuthFooter(
            rightButtonLabel: "Next",
            disableRightButton: !isValidEmail,
            onRightButtonPressed: _getContactMethods,
            leftButtonLabel: "",
            onLeftButtonPressed: () {},
            showLeftButton: false,
          )
        ]),
      ),
    );
  }
}
