import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/user-verification/verification-code-page.dart';
import 'package:gigachat/services/helper-classes/contact-method.dart';
import 'package:gigachat/widgets/login-app-bar.dart';
import 'package:gigachat/widgets/page-description.dart';
import 'package:gigachat/widgets/page-footer.dart';
import 'package:gigachat/widgets/page-title.dart';


class VerificationMethodPage extends StatefulWidget {
  String pageRoute = "/test";
  List<ContactMethod> methods;

  VerificationMethodPage({super.key,required this.methods});

  @override
  State<VerificationMethodPage> createState() => _VerificationMethodPageState();
}

class _VerificationMethodPageState extends State<VerificationMethodPage> {

  late List<ContactMethod> methods;
  ContactMethod? selectedMethod;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    methods = widget.methods;
    selectedMethod = methods[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LoginAppBar(),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(LOGIN_PAGE_PADDING),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle(title: CONFIRMATION_METHOD_TITLE),
            const SizedBox(height: 20),
            const PageDescription(description: CONFIRMATION_METHOD_DESCRIPTION),
            const SizedBox(height: 20),

            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: methods.map((method) =>
                    RadioListTile(
                      title: Text(method.contactWay, style: contactTextStyle()),
                      subtitle: Text(method.contactTarget,style: contactTextStyle()),
                      toggleable: false,
                      activeColor: Colors.blue,

                      contentPadding: const EdgeInsets.all(0),
                      groupValue: selectedMethod,
                      value: method,
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (change){
                        setState(() {
                          selectedMethod = change;
                        });
                      },
                    )
                ).toList(),


            ),

            const Expanded(child: SizedBox()),
            LoginFooter(
              proceedButtonName: "Next",
              showForgetPassword: false,
              showCancelButton: true,
              onPressed: (){
                Navigator.pushNamed(context, VerificationCodePage.pageRoute);
              },
            )

          ],
        ),
      ),
    );
  }
}

TextStyle contactTextStyle()
{
  return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white
  );
}

