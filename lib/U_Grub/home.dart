import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'drawer.dart';
import 'feed.dart';

class GrubHome extends StatefulWidget {
  const GrubHome({
    Key key,
    this.isLightTheme,
    @required this.onThemeChanged,
    this.themeColor,
    this.onColorChanged
  }) :  assert(onThemeChanged != null),
        assert(onColorChanged != null),
        super(key: key);

  final isLightTheme;
  final ValueChanged<bool> onThemeChanged;

  final Color themeColor;
  final ValueChanged<int> onColorChanged;

  @override
  _GrubHomeState createState() => new _GrubHomeState();
}

class _GrubHomeState extends State<GrubHome> {



  @override
  Widget build(BuildContext context) {
    Widget home = new Scaffold(
      drawer: new AppDrawer(
        isLightTheme: widget.isLightTheme,
        onThemeChanged: widget.onThemeChanged,
        themeColor: widget.themeColor,
        onColorChanged: widget.onColorChanged,

      ),

      appBar: new AppBar(
        title: new Text("UGrub"),

      ),

      body: new MainFeed(),



    );


    return home;
  }
}
