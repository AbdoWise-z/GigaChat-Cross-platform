import 'package:flutter/material.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/login/controllers/username-controller.dart';
import 'package:gigachat/pages/login/sub-pages/password-page.dart';

class UsernameLoginPage extends StatefulWidget {
  const UsernameLoginPage({super.key});

  @override
  State<UsernameLoginPage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernameLoginPage> {

  String? username;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = "";
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
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
                  onChanged: (editedUsername){
                    setState(() {
                      username = editedUsername;
                    });
                  },
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
                          onPressed: () async {
                              bool verified = await verifyUsername(username);
                              if (verified)
                              {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder:
                                            (context)=>
                                                PasswordLoginPage(username: username)
                                    )
                                );
                              }
                          },
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
