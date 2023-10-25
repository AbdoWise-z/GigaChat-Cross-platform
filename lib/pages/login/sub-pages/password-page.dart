import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/login/controllers/password-controller.dart';


class PasswordLoginPage extends StatefulWidget {
  String? username;

  PasswordLoginPage({this.username,super.key});


  @override
  State<PasswordLoginPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<PasswordLoginPage> {
  String? username = "";
  bool passwordVisible = false;
  String? password;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.username;
    password = "";
  }

  @override
  Widget build(BuildContext context) {
    IconData passwordState =
    passwordVisible ?
    Icons.visibility_outlined :
    Icons.visibility_off_outlined;

    return Theme(
        data: ThemeData(
            brightness: Brightness.dark,
          disabledColor: const Color(0xffFAFAFA)
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            title: Text(
              APP_NAME.toUpperCase(),
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(PASSWORD_PAGE_DESCRIPTION,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                  ),
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 30),

                TextFormField(
                  onChanged: (email){},
                  initialValue: username,
                  enabled: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  onChanged: (editedPassword){
                    setState(() {
                      password = editedPassword;
                    });
                  },
                  obscureText: ! passwordVisible,
                  autocorrect: false,
                  enableSuggestions: false,

                  decoration: InputDecoration(
                      label:  const Text(PASSWORD_INPUT_LABEL),
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
                                  ),
                                  child: Icon(passwordState)
                              ),
                            ),

                            // verification Icon
                            renderVerificationIcon(password),

                          ],
                        ),
                      ),
                  ),

                const Expanded(child: SizedBox()),

                Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Color(0xff303030))
                      )
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              side: const BorderSide(width:1.1,color:Colors.white),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          onPressed: (){},
                          child: const Text("Forget password?")
                      ),

                      const Expanded(child: SizedBox()),


                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.grey[900],
                              backgroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          onPressed: (){},
                          child: const Text("Next")
                      ),
                    ]
                    ,
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
