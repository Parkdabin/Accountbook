import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class FToast {
  FToast({content}) {
    Fluttertoast.showToast(
        msg: '$content',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.brown[50],
        fontSize: 15.0,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_SHORT);
  }
}
