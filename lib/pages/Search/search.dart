import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gigachat/api/search-requests.dart';
import 'package:gigachat/pages/Search/unit-widgets/search-widgets.dart';
import 'package:gigachat/providers/auth.dart';


const REQUEST_COOLDOWN = Duration(milliseconds: 500);



class SearchPage extends StatefulWidget
{
  static const String pageRoute = "/search";
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? lastSearched;
  String? keyword;
  String? userToken;
  List<String>? searchedTags;
  late TextEditingController textFieldController;
  late Timer timerController;

  void searchKeyword() async {
    if (keyword == null || keyword!.isEmpty) {
      clearList();
      return;
    }
    searchedTags ??= [];
    searchedTags!.addAll(await SearchRequests.searchTagsByKeyword(keyword!, userToken!));
    setState(() {});
  }


  void clearList() {
    searchedTags = [];
    setState(() {});
  }

  void reWriteTimer() {
    timerController.cancel();
    timerController = Timer(REQUEST_COOLDOWN, () { searchKeyword(); });
  }

  @override
  void initState() {
    super.initState();
    textFieldController = TextEditingController();
    keyword = "";
    timerController = Timer(REQUEST_COOLDOWN, () { searchKeyword(); });
  }

  @override
  Widget build(BuildContext context) {
    keyword ??= "";

    try{
      userToken ??= Auth.getInstance(context).getCurrentUser()!.auth;
    } catch (e){
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: textFieldController,
          onChanged: (String newKeyword) {
            // TODO: fetch new search
            reWriteTimer();
            if (keyword!.isEmpty && newKeyword.isNotEmpty ||
                keyword!.isNotEmpty && newKeyword.isEmpty)
            {
              keyword = newKeyword;
              setState(() {});
            }
            keyword = newKeyword;
          },
          style: const TextStyle(color: Colors.blue),
          decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: "Search Gigachat",
              suffixIcon: Visibility(
                visible: textFieldController.text.isNotEmpty,
                child: GestureDetector(
                  child: const Icon(Icons.close,color: Colors.white,),
                  onTap: (){
                    keyword = "";
                    textFieldController.clear();
                    clearList();
                    },
                ),
              )
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: searchedTags == null ? [const SizedBox()] :
          searchedTags!.map((tag) =>
              SearchKeyword(
                tag: tag,
                onIconClick: () {
                  reWriteTimer();
                  textFieldController.text = tag;
                }
              )
          ).toList()
        ),
      ),

    );
  }
}




