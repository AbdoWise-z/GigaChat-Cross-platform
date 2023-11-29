import 'package:flutter/material.dart';

void showCustomModalSheet(BuildContext context, List<List> buttons) async {
  showModalBottomSheet(
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
    ),
    context: context,
    builder: (context) => buildSheet(context, buttons),
  );
}

Widget buildSheet(BuildContext context,List<List> sheetData,) {
  List<Widget> bottomSheetData = sheetData.map((pair) => pair.isEmpty ?
  Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: const Divider(color: Colors.white,height: 3)
  ) :
  modalSheetButton(context, pair[0], pair[1],pair[2])
  ).toList();
  return ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0,10,0,0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: bottomSheetData,
      ),
    ),
  );
}


Widget modalSheetButton(BuildContext context,String content, IconData icon, void Function()? callbackFunction)
{
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(15)
    ),
    onPressed: (){
      if (callbackFunction != null) callbackFunction();
      Navigator.pop(context);
    },
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10,),
        Expanded(child: Text(content,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w400),),),
      ],
    ),
  );
}