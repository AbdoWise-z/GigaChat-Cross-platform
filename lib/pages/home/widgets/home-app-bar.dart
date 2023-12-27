import 'package:flutter/material.dart';
import 'package:gigachat/Globals.dart';
import 'package:gigachat/providers/theme-provider.dart';

/// represents a single action in the home app bar
/// takes [onClick] an event handler to trigger and
/// [icon] the icon to display
class AppBarAction {
  final void Function() onClick;
  final IconData icon;
  const AppBarAction({required this.icon , required this.onClick});
}

/// the search bar inside the home app bar, takes [hint] is
/// the hint text to display and [onClick] a click event
/// handler
class AppBarSearch {
  final String hint;
  final void Function() onClick;
  const AppBarSearch({required this.hint , required this.onClick});
}

/// a structure to hold the app bar tabs
/// takes a list [tabs] the title of these tabs
/// a [indicatorSize] and [tabAlignment]
class AppBarTabs{
  final List<String> tabs;
  final TabBarIndicatorSize? indicatorSize;
  final TabAlignment? tabAlignment;

  AppBarTabs({required this.tabs, required this.indicatorSize, required this.tabAlignment});

}

/// a Stateless widget to build the home app bar
/// takes :
/// [pinned] is the app bar pinned ?
/// [userImage] the link to the current user profile image
/// [title] the title of this app bar (if any)
/// [searchBar] the search par specs
/// [actions] a list of actions that should be included
/// [controller] the tab bar controller is this page has tabs
/// [tabs] the tabs to display if this page has tabs
/// [disableProfileIcon] in wide screen we have more than one app bar
///                      so we use this parameter to disable one of the images
class HomeAppBar extends StatelessWidget {
  final bool pinned;
  final String? userImage;
  final String? title;
  final AppBarSearch? searchBar;
  final List<AppBarAction> actions;
  final TabController? controller;
  final AppBarTabs? tabs;
  final bool disableProfileIcon;

  const HomeAppBar({super.key, required this.pinned, this.userImage, this.title, this.searchBar, required this.actions, this.controller, this.tabs , this.disableProfileIcon = false });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      floating: true,
      snap: true,
      leading: Visibility(
        visible: !Globals.isWideVersion && disableProfileIcon == false,
        child: SizedBox(
          width: 40,
          height: 40,

          child: IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: userImage == null ? const Icon(
                Icons.person_outline_outlined
            ) : Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                width: 34,
                height: 34,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        userImage!,
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    border: Border.all(
                      width: 0,
                    ),
                ),
              ),
            ),
          ),
        ),
      ),
      title: title == null && searchBar == null ? SizedBox(
        height: 30,
        width: 30,
        child: Image.asset(
          ThemeProvider.getInstance(context).isDark() ? 'assets/giga-chat-logo-dark.png' : 'assets/giga-chat-logo-light.png',
        ),
      ) : title == null ? GestureDetector(
        onTap: searchBar!.onClick,
        child: Container(
          constraints: const BoxConstraints.expand(height: 45),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: ThemeProvider.getInstance(context).isDark() ? const Color.fromARGB(30, 200, 255, 235) : const Color.fromARGB(30, 100, 155, 135),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            border: Border.all(
              width: 0.8,
              color: Colors.blueGrey,
            ),
          ),
          child: Text(
            searchBar!.hint,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ) : Text(
        title!,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: actions.map((e) => IconButton(icon: Icon(e.icon), onPressed: e.onClick,)).toList(growable: false),
      bottom: tabs != null && controller != null ? PreferredSize(
        preferredSize: const Size.fromHeight(51),
        child: Container(
          height: 51,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: TabBar(
                  indicatorWeight: 3,
                  //padding: const EdgeInsets.fromLTRB(12, 8, 12, 1), // don't edit the {8 , 1}
                  isScrollable: true,                               // why ? cuz they are magic numbers
                  controller: controller,
                  tabAlignment:  tabs!.tabAlignment,
                  indicatorSize:  tabs!.indicatorSize,
                  tabs: tabs!.tabs.map((e) => Text(e)).toList(growable: false),
                ),
              ),
              Divider(height: 1,thickness: 0.4,color: Colors.blueGrey,),
            ],
          ),
        ),
      ) : null ,
    );
  }
}
