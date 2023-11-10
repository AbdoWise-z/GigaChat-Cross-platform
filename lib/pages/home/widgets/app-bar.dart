import 'package:flutter/material.dart';
import 'package:gigachat/providers/theme-provider.dart';

class AppBarAction {
  final void Function() onClick;
  final IconData icon;
  const AppBarAction({required this.icon , required this.onClick});
}

class AppBarSearch {
  final String hint;
  final void Function() onClick;
  const AppBarSearch({required this.hint , required this.onClick});
}

class AppBarTabs{
  final List<String> tabs;
  final TabBarIndicatorSize? indicatorSize;
  final TabAlignment? tabAlignment;

  AppBarTabs({required this.tabs, required this.indicatorSize, required this.tabAlignment});

}

SliverAppBar buildAppBar(BuildContext context , bool pinned , String? userImage , String? title , AppBarSearch? searchBar  , List<AppBarAction> actions , TabController? controller , AppBarTabs? tabs){
  return SliverAppBar(
    pinned: pinned,
    floating: true,
    snap: true,
    leading: SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: userImage == null ? const Icon(
            Icons.person_outline_outlined
        ) : Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(userImage),
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              border: Border.all(
                width: 0,
              )
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
        constraints: const BoxConstraints.expand(height: 35),
        padding: const EdgeInsets.all(10),
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
      title,
      style: const TextStyle(
        fontSize: 20,
      ),
    ),
    centerTitle: true,
    actions: actions.map((e) => IconButton(icon: Icon(e.icon), onPressed: e.onClick,)).toList(growable: false),
    bottom: tabs != null && controller != null ? TabBar(
      indicatorWeight: 3,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 1), // don't edit the {8 , 1}
      isScrollable: true,                               // why ? cuz they are magic numbers
      controller: controller,
      tabAlignment: tabs.tabAlignment,
      indicatorSize: tabs.indicatorSize,
      tabs: tabs.tabs.map((e) => Text(e)).toList(growable: false),
    ) : null,
  );
}