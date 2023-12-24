import 'package:flutter/material.dart';
import 'FilterSettingsPage.dart';
import 'PreferenceSettingsPage.dart';

class NotificationSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Setting',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.filter),
            title: const Text('Filters'),
            trailing: const Icon(Icons.arrow_forward), // Add a right arrow icon
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FilterSettingsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Preferences'),
            trailing: const Icon(Icons.arrow_forward), // Add a right arrow icon
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PreferenceSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}