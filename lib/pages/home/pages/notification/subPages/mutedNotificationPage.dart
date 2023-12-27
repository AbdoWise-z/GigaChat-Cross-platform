import 'package:flutter/material.dart';

/// this is a preview page, its not complete nor it integrated with the api
/// because this is no API for it
class MutedNotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mute Notification',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              'Mute Notification from people:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckBoxRow(context, 'You do not follow'),
                _buildCheckBoxRow(context, 'Who do not follow You'),
                _buildCheckBoxRow(context, 'With a new account'),
                _buildCheckBoxRow(context, 'Who have a default profile photo'),
                _buildCheckBoxRow(context, 'Who haven’t confirmed their email'),
                _buildCheckBoxRow(context, 'Who haven’t confirmed their phone number'),
                Text('These filters won’t affect notifications from people you follow.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckBoxRow(BuildContext context, String text) {
    bool isChecked = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Checkbox(
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value ?? false;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
