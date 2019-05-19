import 'package:flutter/material.dart';
import 'package:flutterfire_auth/utils/auth.dart';

import 'home.dart';
import 'login_page.dart';

class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth}) : super(key: key);
  final Auth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.auth.currentUser().then((String userId) {
      setState(() {
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  // initState() {
  //   super.initState();
  //   widget.auth.currentUser().then((userId) {
  //     setState(() {
  //       authStatus =
  //           userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
        );
      case AuthStatus.signedIn:
        return new HomePage(
          auth: widget.auth,
        );
      default:
        return _buildWaitingScreen();
    }
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
