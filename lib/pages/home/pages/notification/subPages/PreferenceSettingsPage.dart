import 'package:flutter/material.dart';
import 'PushNotificationPage.dart';
import 'EmailNotificationPage.dart';

class PreferenceSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preference Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notification_add),
            title: Text('Push Notifications'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PushNotificationPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email Notifications'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EmailNotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
