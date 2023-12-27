import 'package:flutter/material.dart';

/// this is a preview page, its not complete nor it integrated with the api
/// because this is no API for it
class PushNotificationPage extends StatelessWidget {
  const PushNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turn on notifications?',
                  style: TextStyle(
                    fontSize: 44.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'To get notifications from Gigachat, you’ll need to allow them in your app settings first.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          // Add additional widgets for other content in the body
        ],
      ),
    );
  }
}
