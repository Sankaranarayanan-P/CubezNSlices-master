import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum NotificationStatus { success, failure, warning }

void showNotificationSnackBar(String message, NotificationStatus status,
    {ToastGravity location = ToastGravity.BOTTOM}) {
  Color colors = Colors.white;
  switch (status) {
    case NotificationStatus.success:
      colors = Colors.green;
      break;
    case NotificationStatus.failure:
      colors = Colors.red;
      break;
    case NotificationStatus.warning:
      colors = Colors.amber;
      break;
  }
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: colors,
      textColor: Colors.white,
      fontSize: 16.0);
}
