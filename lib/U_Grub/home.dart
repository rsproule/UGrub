import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'drawer.dart';
import 'feed.dart';

class GrubHome extends StatefulWidget {
  const GrubHome({
    Key key,
    this.isLightTheme,
    this.currentLocation,
    @required this.onThemeChanged,
    this.themeColor,
    this.onColorChanged,
    @required this.user
  }) :  assert(onThemeChanged != null),
        assert(onColorChanged != null),
        super(key: key);

  final isLightTheme;
  final ValueChanged<bool> onThemeChanged;

  final currentLocation;

  final GoogleSignInAccount user;

  final Color themeColor;
  final ValueChanged<int> onColorChanged;

  @override
  _GrubHomeState createState() => new _GrubHomeState();
}

class _GrubHomeState extends State<GrubHome> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();

  void showDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    Widget drawer = new AppDrawer(
      isLightTheme: widget.isLightTheme,
      onThemeChanged: widget.onThemeChanged,
      themeColor: widget.themeColor,
      onColorChanged: widget.onColorChanged,

    );

    Widget home = new Scaffold(
      key: _scaffoldKey,
      drawer: drawer,

//      appBar: new AppBar(
//        toolbarOpacity: .1,
//      ),

      body: new MainFeed(
        showDrawer: showDrawer,
        user: widget.user,
        currentLocation: widget.currentLocation,
        drawer: drawer
      ),


    );


    return home;
  }
}
