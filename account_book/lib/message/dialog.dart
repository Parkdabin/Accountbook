import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlutterDialog {
  FlutterDialog({title, content, context}) {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: <Widget>[
                new Text(
                  title,
                  style: GoogleFonts.doHyeon(
                    fontSize: 20.0,
                  ),
                ),
                Divider(
                  thickness: 3.0,
                ),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "$content",
                  style: GoogleFonts.doHyeon(fontSize: 17.0),
                ),
              ],
            ),
            actions: <Widget>[
              new ElevatedButton(
                child: new Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
