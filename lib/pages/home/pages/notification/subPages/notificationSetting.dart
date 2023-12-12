import 'package:flutter/material.dart';
import 'FilterSettingsPage.dart';
import 'PreferenceSettingsPage.dart';

class NotificationSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications Setting',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.filter),
            title: Text('Filters'),
            trailing: Icon(Icons.arrow_forward), // Add a right arrow icon
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FilterSettingsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Preferences'),
            trailing: Icon(Icons.arrow_forward), // Add a right arrow icon
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PreferenceSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}