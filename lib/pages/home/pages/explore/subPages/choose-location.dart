import 'package:flutter/material.dart';


/// this is a preview page, its not complete nor it integrated with the api
/// because this is no API for it
class LocationPage extends StatelessWidget {
  final List<String> locations = ['Location A', 'Location B', 'Location C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Location'),
      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(locations[index]),
            onTap: () {
              // Pass the selected location back to the SettingPage
              Navigator.pop(context, locations[index]);
            },
          );
        },
      ),
    );
  }
}