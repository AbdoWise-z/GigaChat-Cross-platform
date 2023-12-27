import 'package:flutter/material.dart';
import 'mutedNotificationPage.dart';

/// this is a preview page, its not complete nor it integrated with the api
/// because this is no API for it
class FilterSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isQualityFilterChecked = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filter Notification Setting',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quality Filter',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Checkbox(
                          value: isQualityFilterChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isQualityFilterChecked = value ?? false;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
                Text(
                    'Choose to filter out content such as duplicate or automated posts. This doesn’t apply to notifications from accounts you follow or have interacted with recently.'),
              ],
            ),
          ),
          ListTile(
            title: Text('Mute notifications'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MutedNotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
