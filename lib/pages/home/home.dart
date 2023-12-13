import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/api/account-requests.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/home/home-page-tab.dart';
import 'package:gigachat/pages/home/pages/chat/chat-home-tab.dart';
import 'package:gigachat/pages/home/pages/explore/explore.dart';
import 'package:gigachat/pages/home/pages/feed/feed-home-tab.dart';
import 'package:gigachat/pages/home/pages/notification/notifications.dart';
import 'package:gigachat/pages/home/pages/search/search-home-tab.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/pages/home/widgets/nav-drawer.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';
import 'package:permission_handler/permission_handler.dart';


class Home extends StatefulWidget {
  static const String pageRoute = "/home";
  static const String feedID = "HomeFeed";
  const Home({super.key});


  @override
  State<Home> createState() => HomeState();


}

class HomeState extends State<Home> with TickerProviderStateMixin {
  TabController? _controller;
  bool _hidBottomControls = false;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  late FeedController followingFeedController;

  //TODO: @Osama @Adel , replace with your pages
  late final List<HomePageTab> _pages = [
    FeedHomeTab(),
    Explore(),
    ChatHomeTab(),
    Notifications(),
    ChatHomeTab(),
  ];

  void update(void Function() callback){
    setState(callback);
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
    // MOA Was Here
    followingFeedController = FeedProvider.getInstance(context).
    getFeedControllerById(
        context: context,
        id: Home.feedID,
        providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
        clearData: false
    );

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
    if (value.getCurrentUser() != null) {
      followingFeedController.setUserToken(value.getCurrentUser()!.auth);
    }
    //print("update");
    return SafeArea(
      child: Scaffold(
        drawerDragStartBehavior: DragStartBehavior.start,
        drawer: const NavDrawer(),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (_ , __) => [
            HomeAppBar(
              pinned: _pages[_currentPage].isAppBarPinned(context),
              userImage: isLoggedIn ? value.getCurrentUser()!.iconLink : null,
              title: _pages[_currentPage].getTitle(context), /* title (if given a value it will show it instead of the search) */
              searchBar: _pages[_currentPage].getSearchBar(context),
              actions: _pages[_currentPage].getActions(context),
              controller: _controller,
              tabs: _pages[_currentPage].getTabs(context),
            ),

          ], body: _controller != null ? Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: _pages[_currentPage].getTabsWidgets(context,feedController: followingFeedController)!,
                ),
              ),
            ],
          ) : _pages[_currentPage].getPage(context)!,
        ),
        floatingActionButton: _hidBottomControls && !_pages[_currentPage].isBottomNavPinned(context) ? null : _pages[_currentPage].getFloatingActionButton(context),
        bottomNavigationBar: AnimatedContainer(
          height: _hidBottomControls && !_pages[_currentPage].isBottomNavPinned(context) ? 0 : 50,
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

