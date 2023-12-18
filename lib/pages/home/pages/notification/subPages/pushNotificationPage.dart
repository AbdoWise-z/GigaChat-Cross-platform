import 'package:flutter/material.dart';

class PushNotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notifications'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                  'To get notifications from X, you’ll need to allow them in your browser settings first.',
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
