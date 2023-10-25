import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';

class LoginPage extends StatefulWidget {
  static const String pageRoute = "/login";
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return
      Theme(
          data: ThemeData(
            brightness: Brightness.dark
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
                children: [
                  const Text(LOGIN_PAGE_DESCRIPTION,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    onChanged: (email){},
                    decoration: const InputDecoration(
                      label:  Text(USERNAME_INPUT_LABEL),
                      border: OutlineInputBorder()
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
