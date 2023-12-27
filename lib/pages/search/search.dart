import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gigachat/api/search-requests.dart';
import 'package:gigachat/api/user-class.dart';
import 'package:gigachat/pages/Search/unit-widgets/search-widgets.dart';
import 'package:gigachat/pages/search/search-result.dart';
import 'package:gigachat/providers/auth.dart';


const REQUEST_COOLDOWN = Duration(milliseconds: 500);

/// page to provide the searching functionality for the user
/// searching is done when the input of the text field changes with a cool down
/// equal to [REQUEST_COOLDOWN]
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
  List<User>? searchedUsers;
  late TextEditingController textFieldController;
  late Timer timerController;

  /// send request to the api endpoint to fetch tags and users to show them in search page
  void searchKeyword() async {
    if (keyword == null || keyword!.isEmpty) {
      clearList();
      return;
    }
    searchedTags ??= [];
    searchedUsers ??= [];
    searchedTags = await SearchRequests.searchTagsByKeyword(keyword!, userToken!);
    searchedUsers = await SearchRequests.searchUsersByKeyword(keyword!, userToken!,"1","5");
    setState(() {});
  }

  /// clear data of the page
  void clearList() {
    searchedTags = [];
    searchedUsers = [];
    setState(() {});
  }

  /// reset cooldown timer
  void reWriteTimer() {
    timerController.cancel();
    timerController = Timer(REQUEST_COOLDOWN, () { searchKeyword(); });
  }

  /// navigate to search results page with the [data] to be searched
  void search(String? data){
    if (data == null || data.isEmpty) {
      return;
    }
    Navigator.pushNamed(context, SearchResultPage.pageRoute,arguments: {"keyword":data});
  }

  @override
  void initState() {
    super.initState();
    clearList();
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
          autofocus: true,
          controller: textFieldController,
          onChanged: (String newKeyword) {
            reWriteTimer();
            if (keyword!.isEmpty && newKeyword.isNotEmpty ||
                keyword!.isNotEmpty && newKeyword.isEmpty)
            {
              keyword = newKeyword;
              setState(() {});
            }
            keyword = newKeyword;
          },
          onSubmitted: (data){
            search(data);
          },
          style: const TextStyle(color: Colors.blue),
          decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: "Search Gigachat",
              suffixIcon: Visibility(
                visible: textFieldController.text.isNotEmpty,
                child: GestureDetector(
                  child: const Icon(Icons.close,),
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

          children: [
            ...searchedTags!.map((tag) => SearchKeyword(
              tag: tag,
              onIconClick: () {
                textFieldController.text = tag;
                keyword = tag;
                reWriteTimer();
              }, onPressed: () { search(tag); },
            )),
            searchedTags!.isNotEmpty ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ) : const SizedBox.shrink(),
            ...searchedUsers!.map((User user) => UserResult(user: user, disableFollowButton: true)).toList()
          ]
        ),
      ),

    );
  }
}




