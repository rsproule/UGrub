import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

//routing (if I need it)




class GrubApp extends StatefulWidget {
  const GrubApp({
    @required this.user
});

  final GoogleSignInAccount user;
  @override
  _GrubAppState createState() => new _GrubAppState();
}

class _GrubAppState extends State<GrubApp> {
  bool _isLightTheme = true;
  Color _themeColor = Colors.blue;



  getThemeFromPreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _isLightTheme = pref.getBool("isLightTheme") != null ? pref.getBool("isLightTheme") : _isLightTheme;

      _themeColor = pref.getBool("isLightTheme") != null ? new Color(pref.getInt("themeColor")) : _themeColor;

    });

    }

  @override
  void initState() {
    super.initState();
    getThemeFromPreference();
  }


  @override
  Widget build(BuildContext context) {

    final ThemeData _lightTheme = new ThemeData(
        accentColor: _themeColor,
        primaryColor: _themeColor,
        brightness: Brightness.light
    );

    final ThemeData _darkTheme = new ThemeData(
        accentColor: _themeColor,
        brightness: Brightness.dark
    );

    Widget home = new GrubHome(
      user: widget.user,
      isLightTheme: _isLightTheme,
      onThemeChanged: (bool val) async {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool('isLightTheme', val);
        setState(() {
          _isLightTheme = val;
        });
      },
      themeColor: _themeColor,
      onColorChanged: (int c) async {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt("themeColor", c);
        setState(() {
          _themeColor = new Color(c);
        });
      },
    );


    return new MaterialApp(
        title: "U Grub",
        home: home,
        theme: _isLightTheme ? _lightTheme : _darkTheme.copyWith(
            accentColor: _themeColor)
    );
  }
}

