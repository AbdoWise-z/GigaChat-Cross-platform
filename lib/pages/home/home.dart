import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/pages/feed/feed-home-tab.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/pages/home/widgets/home-page-tab-example.dart';
import 'package:gigachat/pages/home/widgets/nav-drawer.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:permission_handler/permission_handler.dart';


class Home extends StatefulWidget {
  static const String pageRoute = "/";
  const Home({super.key});


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  TabController? _controller;
  bool _hidBottomControls = false;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;

  //TODO: @Osama @Adel , replace with your pages
  final List<HomePageTab> _pages = [
    FeedHomeTab(),
    DummyPage(),
    DummyPage(),
    DummyPage(),
    DummyPage(),
  ];


  Future<void> test() async{
    //TODO: was just testing the upload function
    Permission.manageExternalStorage.request();
    var f = File("/sdcard/Download/0ac84d5117148db057942650cf7c23c1.jpg");
    print (await f.length());
    await f.readAsBytes();

    var k = await Account.apiSetProfileImage(
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1NTExZjExYTYzYzQ4NmMyNjVjYzFmNiIsImlhdCI6MTY5OTgxNzU2MiwiZXhwIjoxNzA3NTkzNTYyfQ.e_M-aIScz4zagCyuV3guFcUED4zYuYm7RSrp1vnei1A",
      f,
    );
    print("code: ${k.code}");
    print(k.responseBody);
  }

  void setPage(int p){
    _controller = null;
    AppBarTabs? tabs = _pages[p].getTabs(context);
    if (tabs != null && tabs.tabs.isNotEmpty){
      _controller = TabController(
        initialIndex: _pages[p].getInitialTab(context),
        length: tabs.tabs.length,
        vsync: this,
      );
    }

    setState(() {
      //the controller is ready .. lesgo
      _currentPage = p;
    });
  }

  @override
  void initState() {
    //test();
    super.initState();
    setPage(0);
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.offset > 0){
        //we are hitting the bottom edge --> hide the bottom sheet and FAB
        setState(() {
          _hidBottomControls = true;
        });
      }else{
        if (_hidBottomControls){
          setState(() {
            _hidBottomControls = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Auth.getInstance(context).isLoggedIn;
    Auth value = Auth.getInstance(context);

    print("update");

    return SafeArea(
      child: Scaffold(
        drawerDragStartBehavior: DragStartBehavior.start,
        drawer: const NavDrawer(),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (ctx , innerBoxIsScrolled) => <Widget>[
            HomeAppBar(
              pinned: _pages[_currentPage].isAppBarPinned(context),
              userImage: isLoggedIn ? value.getCurrentUser()!.iconLink : null,
              title: _pages[_currentPage].getTitle(context), /* title (if given a value it will show it instead of the search) */
              searchBar: _pages[_currentPage].getSearchBar(context),
              actions: _pages[_currentPage].getActions(context),
              controller: _controller,
              tabs: _pages[_currentPage].getTabs(context),
            ),
          ],
          body: _controller != null ? TabBarView(
            controller: _controller,
            children: _pages[_currentPage].getTabsWidgets(context)!,
          ) : _pages[_currentPage].getPage(context)!,
        ),
        floatingActionButton: _hidBottomControls ? null : _pages[_currentPage].getFloatingActionButton(context),
        bottomNavigationBar: AnimatedContainer(
          height: _hidBottomControls ? 0 : 50,
          duration: const Duration(milliseconds: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0 , horizontal: 16),
            child: Row(
              children: [

                BottomBarItem(
                  icon: _currentPage == 0 ? Icons.home : Icons.home_outlined,
                  click: () => setPage(0),
                  notify: _pages[0].getNotificationsCount(context),
                ),

                const Expanded(child: SizedBox()),

                BottomBarItem(
                  icon: _currentPage == 1 ? Icons.saved_search_sharp : Icons.search_outlined,
                  click: () => setPage(1),
                  notify: _pages[1].getNotificationsCount(context),
                ),

                const Expanded(child: SizedBox()),

                BottomBarItem(
                  icon: _currentPage == 2 ? Icons.people : Icons.people_outline,
                  click: () => setPage(2),
                  notify: _pages[2].getNotificationsCount(context),
                ),

                const Expanded(child: SizedBox()),

                BottomBarItem(
                  icon: _currentPage == 3 ? Icons.notifications : Icons.notifications_none_outlined,
                  click: () => setPage(3),
                  notify: _pages[3].getNotificationsCount(context),
                ),

                const Expanded(child: SizedBox()),

                BottomBarItem(
                  icon: _currentPage == 4 ? Icons.messenger : Icons.messenger_outline,
                  click: () => setPage(4),
                  notify: _pages[4].getNotificationsCount(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class BottomBarItem extends StatelessWidget {
  final void Function() click;
  final IconData icon;
  final int notify;

  const BottomBarItem({super.key , required this.icon , required this.click , required this.notify});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          IconButton(
            onPressed: click,
            icon: Icon(icon,),
            iconSize: 32,
          ),
          Visibility(
            visible: notify != 0,
            child: notify < 0 ? const Padding(
              padding: EdgeInsets.only(left: 30 , top: 10),
              child: Icon(Icons.circle , color: Colors.blueAccent, size: 10,),
            ) : Padding(
              padding: const EdgeInsets.only(left: 25 , top: 5),
              child: Stack(
                children: [
                  const Icon(Icons.circle , color: Colors.blueAccent, size: 15,),
                  Container(
                    width: 15,
                    height: 15,
                    alignment: Alignment.center,
                    child: Text(
                      "${notify < 10 ? notify : "9+"}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 8,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

