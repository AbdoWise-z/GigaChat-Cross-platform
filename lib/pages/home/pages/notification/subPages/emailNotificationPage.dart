import 'package:flutter/material.dart';

/// this is a preview page, its not complete nor it integrated with the api
/// because this is no API for it
class EmailNotificationPage extends StatefulWidget {
  @override
  _EmailNotificationPageState createState() => _EmailNotificationPageState();
}

class _EmailNotificationPageState extends State<EmailNotificationPage> {
  bool enableEmailNotifications = true;
  bool isCheckBoxChecked1 = false;
  bool isCheckBoxChecked2 = false;
  bool isCheckBoxChecked3 = false;
  bool isCheckBoxChecked4 = false;
  bool isCheckBoxChecked5 = false;
  bool isCheckBoxChecked6 = false;
  bool isCheckBoxChecked7 = false;
  bool isCheckBoxChecked8 = false;
  bool isCheckBoxChecked9 = false;
  bool isCheckBoxChecked10 = false;
  bool isCheckBoxChecked11 = false;
  bool isCheckBoxChecked12 = false;
  String selectedComboBoxValue = 'Off';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' Email Notifications',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // First Section
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enable Email Notifications',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: enableEmailNotifications,
                        onChanged: (value) {
                          setState(() {
                            enableEmailNotifications = value;
                            if (!enableEmailNotifications) {
                              isCheckBoxChecked1 = false;
                              isCheckBoxChecked2 = false;
                              isCheckBoxChecked3 = false;
                              isCheckBoxChecked4 = false;
                              selectedComboBoxValue = 'Off';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Text('Get emails to find out what’s going on when you’re not on X. You can turn them off anytime.'),
                ],
              ),
            ),
            // Second Section
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Related to you and your posts',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildCheckboxField('New notifications', isCheckBoxChecked1, 1),
                  _buildCheckboxField('Direct messages', isCheckBoxChecked2, 2),
                  _buildCheckboxField('Posts emailed to you', isCheckBoxChecked3, 3),
                  _buildCheckboxField('Updates about the performance of your posts', isCheckBoxChecked4, 4),
                  _buildComboBoxField(),
                ],
              ),
            ),
            // Third Section
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From GigaChat',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildCheckboxField('News about X product and feature updates', isCheckBoxChecked5, 5),
                  _buildCheckboxField('Tips on getting more out of X', isCheckBoxChecked6, 6),
                  _buildCheckboxField('Things you missed since you last logged into X', isCheckBoxChecked7, 7),
                  _buildCheckboxField('News about X on partner products and other third party services', isCheckBoxChecked8, 8),
                  _buildCheckboxField('Participation in X research surveys', isCheckBoxChecked9, 9),
                  _buildCheckboxField('Suggestions for recommended accounts', isCheckBoxChecked10, 10),
                  _buildCheckboxField('Suggestions based on your recent follows', isCheckBoxChecked11, 11),
                  _buildCheckboxField('Tips on X business products', isCheckBoxChecked12, 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxField(String text, bool isChecked, int checkboxNumber) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 3,
            overflow: TextOverflow.visible, // Overflow behavior
          ),
        ),
        Checkbox(
          value: isChecked,
          onChanged: enableEmailNotifications
              ? (value) {
            setState(() {
              switch (checkboxNumber) {
                case 1:
                  isCheckBoxChecked1 = value ?? false;
                  break;
                case 2:
                  isCheckBoxChecked2 = value ?? false;
                  break;
                case 3:
                  isCheckBoxChecked3 = value ?? false;
                  break;
                case 4:
                  isCheckBoxChecked4 = value ?? false;
                  break;
                  case 5:
                  isCheckBoxChecked5 = value ?? false;
                  break;
                case 6:
                  isCheckBoxChecked6 = value ?? false;
                  break;
                case 7:
                  isCheckBoxChecked7 = value ?? false;
                  break;
                case 8:
                  isCheckBoxChecked8 = value ?? false;
                  break;
                  case 9:
                  isCheckBoxChecked9 = value ?? false;
                  break;
                case 10:
                  isCheckBoxChecked10 = value ?? false;
                  break;
                case 11:
                  isCheckBoxChecked11 = value ?? false;
                  break;
                case 12:
                  isCheckBoxChecked12 = value ?? false;
                  break;
              }
            });
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildComboBoxField() {
    final List<String> choices = ['Daily', 'Weekly', 'Periodically', 'Off'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Top posts and Stories',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<String>(
          value: selectedComboBoxValue,
          items: choices.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: enableEmailNotifications
              ? (String? value) {
            setState(() {
              selectedComboBoxValue = value ?? 'Off';
            });
          }
              : null,
        ),
      ],
    );
  }
}
