import 'package:flutter/material.dart';

/// Widget that view to user that a permission is missing
/// [onClick] call back function on pressing got it button
class RequestPermissions extends StatelessWidget {
  final void Function() onClick;
  const RequestPermissions({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Expanded(flex: 1,child: SizedBox(),),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Hmmm ... seems like we're missing some permissions" ,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Gigachat needs to have access to the gallery to be able to upload images." ,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
          ),

          const Expanded(flex: 1,child: SizedBox(),),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25))
                  )
              ),
              onPressed: onClick,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40 , vertical: 5),
                child: Text(
                  "Got it",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          ),

          const Expanded(flex: 3,child: SizedBox(),),
        ],
      ),
    );
  }
}
