import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/base.dart';
import 'package:gigachat/pages/Search/search.dart';
import 'package:gigachat/pages/home/home.dart';
import 'package:gigachat/pages/home/widgets/home-app-bar.dart';
import 'package:gigachat/pages/home/widgets/home-bottom-bar-item.dart';
import 'package:gigachat/providers/auth.dart';
import 'package:gigachat/providers/feed-provider.dart';
import 'package:gigachat/widgets/feed-component/feed-controller.dart';

import '../widgets/nav-drawer.dart';

///
/// This this the entire home widget of the app
/// its responsible for displaying the various pages (feed, search, ...)
/// and manging the state and the switching between such pages
///
class InternalHomePage extends StatefulWidget {
  static final String pageRoute = "/internal-home";

  const InternalHomePage({super.key});

  @override
  State<InternalHomePage> createState() => InternalHomePageState();

  static GlobalKey<NestedScrollViewState>? getScrollGlobalKey(BuildContext context){
    InternalHomePageState? state = context.findAncestorStateOfType<InternalHomePageState>();
    if (state == null){
      return null;
    }
    return state.nestedScrollViewKey;
  }
}

class InternalHomePageState extends State<InternalHomePage> with TickerProviderStateMixin {
  /// used to get the home current home state of the app
  /// without the use of BuildContext or from outside its
  /// tree
  static InternalHomePageState? ActiveHomeState;


  bool _hidBottomControls = false;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  late FeedController followingFeedController;

  //I use this key to refresh the NestedScrollView
  //to prevent SliverAppBar problems
  GlobalKey<NestedScrollViewState> nestedScrollViewKey = GlobalKey();

  /// sets the current active page of the home pages
  /// takes only one parameter [p] which is the page
  /// index
  void setPage(int p){
    AppBarTabs? tabs = Home.Pages[p].getTabs(context);
    if (tabs != null && tabs.tabs.isNotEmpty){
      Home.Controllers[p] = TabController(
        initialIndex: Home.Pages[p].getInitialTab(context),
        length: tabs.tabs.length,
        vsync: this,
      );
    }

    setState(() {
      //the controller is ready .. lesgo
      _currentPage = p;
      nestedScrollViewKey = GlobalKey();
    });
  }

  /// updates this home state
  void update(void Function() callback){
    setState(callback);
  }

  @override
  void initState() {
    super.initState();
    // MOA Was Here
    followingFeedController = FeedProvider.getInstance(context).
    getFeedControllerById(
        context: context,
        id: Home.feedID,
        providerFunction: ProviderFunction.HOME_PAGE_TWEETS,
        clearData: false
    );
    // MoA left here

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

    if (!value.isLoggedIn){
      return SizedBox.shrink();
    }

    if (value.getCurrentUser() != null) {
      followingFeedController.setUserToken(value.getCurrentUser()!.auth);
    }

    if (_currentPage == 3 && Globals.isChatSeparated){
      int p = 0;
      AppBarTabs? tabs = Home.Pages[p].getTabs(context);
      if (tabs != null && tabs.tabs.isNotEmpty){
        Home.Controllers[p] = TabController(
          initialIndex: Home.Pages[p].getInitialTab(context),
          length: tabs.tabs.length,
          vsync: this,
        );
      }
      _currentPage = p;
      nestedScrollViewKey = GlobalKey();
      if (Globals.currentActiveChat != null){
        Future.delayed(Duration.zero , () {
          Navigator.pop(context); //pop that chat
        });
      }
    }
    return SafeArea(
      child: Row(
        children: [
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
            child: Visibility(
              visible: Globals.isWideVersion ,
              child: SizedBox(
                width: 300,
                height: double.infinity,
                child: NavDrawer(),
              ),
            ),
          ),

          VerticalDivider(width: 2,thickness: 2,),

          Expanded(
            child: Scaffold(
              drawerDragStartBehavior: DragStartBehavior.start,
              drawer: Globals.isWideVersion ? null : const NavDrawer(),
              body: NestedScrollView(
                key: nestedScrollViewKey,
                controller: _scrollController,
                floatHeaderSlivers: true,
                headerSliverBuilder: (_ , __ ) {
                  return [
                    HomeAppBar(
                      pinned: Home.Pages[_currentPage].isAppBarPinned(context),
                      userImage: isLoggedIn ? value.getCurrentUser()!.iconLink : null,
                      title: Home.Pages[_currentPage].getTitle(context), /* title (if given a value it will show it instead of the search) */
                      searchBar: Home.Pages[_currentPage].getSearchBar(context),
                      actions: Home.Pages[_currentPage].getActions(context),
                      controller: Home.Controllers[_currentPage],
                      tabs: Home.Pages[_currentPage].getTabs(context),
                    ),
                  ];
                },
                body: Home.Controllers[_currentPage] != null ? TabBarView(
                  controller: Home.Controllers[_currentPage],
                  children: Home.Pages[_currentPage].getTabsWidgets(context,feedController: followingFeedController)!,
                ) : Home.Pages[_currentPage].getPage(context)!,

              ),
              floatingActionButton: Platform.isWindows == false && _hidBottomControls && !Home.Pages[_currentPage].isBottomNavPinned(context) ? null : Home.Pages[_currentPage].getFloatingActionButton(context),
              bottomNavigationBar: AnimatedContainer(
                height: Platform.isWindows == false && _hidBottomControls && !Home.Pages[_currentPage].isBottomNavPinned(context) ? 0 : 51,
                duration: const Duration(milliseconds: 100),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Divider(height: 1, thickness: 0.4, color: Colors.blueGrey,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0 , horizontal: 16),
                        child: Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            BottomBarItem(
                              icon: _currentPage == 0 ? Icons.home : Icons.home_outlined,
                              click: () {
                                if (_currentPage == 0){
                                  Home.Pages[0].reload(context);
                                }else{
                                  setPage(0);
                                }
                              },
                              notify: Home.Pages[0].getNotificationsCount(context),
                            ),
                            const Expanded(flex: 2,child: SizedBox(),),
                            BottomBarItem(
                              icon: _currentPage == 1 ? Icons.saved_search_sharp : Icons.search_outlined,
                              click: () {
                                if (_currentPage == 1) {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) {
                                        return const SearchPage();
                                      },
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        var tween = Tween(begin: 0.0, end: 1.0);
                                        var fadeAnimation = tween.animate(animation);
                                        return FadeTransition(
                                          opacity: fadeAnimation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  setPage(1);
                                }
                              },
                              notify: Home.Pages[1].getNotificationsCount(context),
                            ),
                            const Expanded(flex: 2,child: SizedBox(),),
                            BottomBarItem(
                              icon: _currentPage == 2 ? Icons.notifications : Icons.notifications_none_outlined,
                              click: () {
                                if (_currentPage == 2){
                                  Home.Pages[2].reload(context);
                                }else{
                                  setPage(2);
                                }
                              },
                              notify: Home.Pages[2].getNotificationsCount(context),
                            ),
                            Visibility(
                              visible: !Globals.isChatSeparated,
                              child: const Expanded(flex: 2,child: SizedBox(),),
                            ),
                            Visibility(
                              visible: !Globals.isChatSeparated,
                              child: BottomBarItem(
                                icon: _currentPage == 3 ? Icons.messenger : Icons.messenger_outline,
                                click: () {
                                  if (_currentPage == 3){
                                    Home.Pages[3].reload(context);
                                  }else{
                                    setPage(3);
                                  }
                                },
                                notify: Home.Pages[3].getNotificationsCount(context),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
