import 'package:flutter/material.dart';
import 'package:gigachat/api/chat-class.dart';
import 'package:gigachat/api/chat-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-item.dart';
import 'package:gigachat/pages/home/pages/chat/widgets/chat-list-item.dart';
import 'package:gigachat/providers/auth.dart';

import 'chat-page.dart';

class ChatSearchPage extends StatefulWidget {
  const ChatSearchPage({super.key});

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  TextEditingController textEditingController = TextEditingController();
  final List<ChatObject> _results = [];

  bool _searching = false;
  void _doSearch(String keyword) async {
    if (keyword.isEmpty) return;
    if (_searching) return;
    _searching = true;
    setState(() {});
    var k = await Chat.apiSearchChat(Auth().getCurrentUser()!.auth!, keyword);
    if (k.data == null){
      setState(() {
        _searching = false;
        _results.clear();
        if (textEditingController.text != keyword){
          Future.delayed(Duration.zero , () {
            _doSearch(textEditingController.text);
          });
        }
      });
    }else{
      setState(() {
        _searching = false;
        _results.clear();
        _results.addAll(k.data!);
        for (ChatObject i in _results){
          i.lastMessage!.seen = true;
        }
        if (textEditingController.text != keyword){
          Future.delayed(Duration.zero , () {
            _doSearch(textEditingController.text);
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      _doSearch(textEditingController.text); //spam the hell out of them
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          controller: textEditingController,
          onChanged: (String newKeyword) {

          },
          onSubmitted: (data){

          },
          style: const TextStyle(color: Colors.blue),
          decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: "Search Direct Messages",
              suffixIcon: _searching ? const SizedBox(
                width: 40,
                height: 40,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ) : Visibility(
                visible: textEditingController.text.isNotEmpty,
                child: GestureDetector(
                  child: const Icon(Icons.close,color: Colors.white,),
                  onTap: (){
                    textEditingController.clear();
                  },
                ),
              )
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...
              _results.map((e) => ChatListItem(
                object: e,
                longPress: () {
                  //_createDialog(e);
                },
                press: () async {
                  Navigator.pushNamed(context, ChatPage.pageRoute , arguments: {
                    "user" : User(id: e.username , name: e.nickname , iconLink: e.profileImage, mongoID: e.mongoID, isFollowed: e.followed, isBlocked: e.blocked),
                    "message" : e.lastMessage,
                  });
                },
              )).toList(),

            ],
        ),
      ),

    );
  }
}
