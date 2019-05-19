import 'package:flutter/material.dart';
import 'flutter_license.dart';

class Static {
  static void showSnackbar(BuildContext context, SnackBarInfo snackBarInfo) {
    if (snackBarInfo.showSnackBar)
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(snackBarInfo.msg),
          backgroundColor: Colors.black,
          duration: new Duration(seconds: snackBarInfo.duration),
          action: snackBarInfo.action));
  }

  static Future<void> showAboutDialog(BuildContext context) async {
    addLicenses();
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AboutDialog(
            applicationName: 'App Name',
            applicationVersion: '1.0',
            // applicationIcon: new Image.asset('assets/images/applogo.png',
                // width: 48, height: 48),
            applicationLegalese: 'PUT COPYRIGHT HERE',
            children: <Widget>[
              //Text('Testing')
            ],
          );
        });
  }
}

class SnackBarInfo {
  String msg;
  int duration;
  bool showSnackBar;
  SnackBarAction action;
  SnackBarInfo(this.msg, this.duration, this.showSnackBar, {this.action});
}
