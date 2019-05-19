import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:dynamic_theme/theme_switcher_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_auth/utils/constants.dart';

import '../utils/auth.dart';
import '../utils/static.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.snackBarInfo});
  final Auth auth;
  final SnackBarInfo snackBarInfo;

  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Static.showSnackbar(_context, widget.snackBarInfo));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('App Name'),
          actions: <Widget>[
            new PopupMenuButton<String>(
              onSelected: _choiceAction,
              itemBuilder: (BuildContext context) {
                return Constants.choices.map((String choice) {
                  return PopupMenuItem<String>(
                      value: choice, child: Text(choice));
                }).toList();
              },
            )
          ],
        ),
        body: new Builder(builder: (BuildContext context) {
          _context = context;
        return new Center(child: Text("Hello"));
        }));
  }

//Possibly going to move _choiceAction and _signOut and new PopupMenu to the static class
  void _choiceAction(String choice) {
    if (choice == Constants.Settings) {
      print('Settings');
      showChooser();
    } else if (choice == Constants.LogOut) {
      _signOut();
      print('Log out');
    } else if (choice == Constants.About) {
      Static.showAboutDialog(_context);
      print('About');
    }
  }

  void showChooser() {
    showDialog<void>(
        context: context,
        builder: (context) {
          return BrightnessSwitcherDialog(
            onSelectedTheme: (brightness) {
              DynamicTheme.of(context).setBrightness(brightness);
            },
          );
        });
  }

  // void changeBrightness() {
  //   DynamicTheme.of(context).setBrightness(
  //       Theme.of(context).brightness == Brightness.dark
  //           ? Brightness.light
  //           : Brightness.dark);
  // }

  // void changeColor() {
  //   DynamicTheme.of(context).setThemeData(ThemeData(
  //       primaryColor: Theme.of(context).primaryColor == Colors.indigo
  //           ? Colors.red
  //           : Colors.indigo));
  // }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => new LoginPage(
                    auth: widget.auth,
                    snackBarInfo:
                        new SnackBarInfo('Logged out Successfully', 3, true),
                  )));
    } catch (e) {
      Static.showSnackbar(
          _context, new SnackBarInfo('Sign out error', 3, true));
      print(e);
    }
  }
}
