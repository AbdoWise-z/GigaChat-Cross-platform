import 'package:flutter/material.dart';
import 'PushNotificationPage.dart';
import 'EmailNotificationPage.dart';

class PreferenceSettingsPage extends StatelessWidget {
  const PreferenceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preference Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notification_add),
            title: const Text('Push Notifications'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PushNotificationPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email Notifications'),
            trailing: const Icon(Icons.arrow_forward),
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
