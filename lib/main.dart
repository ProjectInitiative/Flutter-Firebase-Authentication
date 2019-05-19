import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutterfire_auth/utils/auth.dart';

import 'pages/root_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) =>
          new ThemeData(primarySwatch: Colors.indigo, brightness: brightness),
      themedWidgetBuilder: (context, theme) {
        return new MaterialApp(
          title: 'App Name',
          theme: theme,
          home: new RootPage(auth: new Auth()),
        );
      },
    );
  }
}
