import 'package:flutter/material.dart';

/// just a widget to represent a button that will be
/// used on the Bottom Navigation Bar in the home page
/// takes [icon] the icon of this button , [click] a
/// click event handler and [notify] the number of notifications
/// this page has
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