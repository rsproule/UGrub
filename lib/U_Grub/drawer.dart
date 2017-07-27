import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class AppDrawer extends StatefulWidget {
  const AppDrawer({
    Key key,
    this.isLightTheme,
    @required this.onThemeChanged,
    this.themeColor,
    this.onColorChanged
  })
      : assert(onThemeChanged != null),
        assert(onColorChanged != null),
        super(key: key);

  final isLightTheme;
  final ValueChanged<bool> onThemeChanged;

  final Color themeColor;
  final ValueChanged<int> onColorChanged;

  @override
  _AppDrawerState createState() => new _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  @override
  Widget build(BuildContext context) {
    final double systemTopPadding = MediaQuery
        .of(context)
        .padding
        .top;

    final Widget lightThemeButton = new RadioListTile<bool>(
        secondary: const Icon(Icons.brightness_high),
        title: const Text("Light"),
        value: true,
        groupValue: widget.isLightTheme,
        onChanged: widget.onThemeChanged
    );

    final Widget darkThemeButton = new RadioListTile<bool>(
        secondary: const Icon(Icons.brightness_low),
        title: const Text("Dark"),
        value: false,
        groupValue: widget.isLightTheme,
        onChanged: widget.onThemeChanged
    );

    final List<DropdownMenuItem> colors = [
      new DropdownMenuItem(
        child: new Container(padding: const EdgeInsets.all(4.0),
          child: new Text("RED", style: new TextStyle(color: Colors.red),),
        ),
        value: Colors.red.value,
      ),
      new DropdownMenuItem(
        child: new Container(padding: const EdgeInsets.all(4.0),
          child: new Text("BLUE", style: new TextStyle(color: Colors.blue),),
        ),
        value: Colors.blue.value,
      ),
      new DropdownMenuItem(
        child: new Container(padding: const EdgeInsets.all(4.0),
          child: new Text("GREEN", style: new TextStyle(color: Colors.green),),
        ),
        value: Colors.green.value,
      ),
      new DropdownMenuItem(
        child: new Container(padding: const EdgeInsets.all(4.0),
          child: new Text(
            "ORANGE", style: new TextStyle(color: Colors.orange),),
        ),
        value: Colors.orange.value,
      ),
    ];

    final Widget colorSelector = new Container(
      alignment: FractionalOffset.bottomLeft,
      padding: const EdgeInsets.only(left: 30.0),
      child: new DropdownButton<int>(
        value: widget.themeColor.value,

        items: colors,
        onChanged: widget.onColorChanged,
//        style: new TextStyle(),
      ),

    );


    final Widget settingsTab = new ExpansionTile(
      title: new Text("Settings"),
      leading: new Icon(Icons.settings),
      children: <Widget>[
        new Center(child: new Text("Brightness"), heightFactor: 2.0,),
        lightThemeButton,
        darkThemeButton,
        const Divider(),
        new Container(
          child: new Text("Theme Color"), padding: const EdgeInsets.all(5.0),),
        colorSelector

      ],

    );

    final Widget header = new Container(
//      decoration: new BoxDecoration(
//        image: new DecorationImage(
//            image: new AssetImage("assets/images/HeaderLogo.jpeg")
//        )
//      ),
      child: new Image.asset("assets/images/full_clear_back.png"),
      padding: new EdgeInsets.only(top: systemTopPadding),

    );

    final Widget appInfo = new AboutListTile(
      applicationVersion: "v2.0.0",
      applicationName: "UGrub",
      applicationLegalese: "Ryan Sproule ® 2017",
      applicationIcon: new Container(
        child: new Image.asset("assets/images/logo_clear_back.png"),
        width: 80.0,

      ),

      icon: new Icon(Icons.info_outline),
    );


    final List<Widget> _allDrawerItems = <Widget>[
      header,
      new Divider(height: 0.0,),
      settingsTab,
      new Divider(height: 0.0,),
      appInfo,
      new Divider(height: 0.0,),

    ];


    return new Drawer(

        child: new ListView(
          primary: false,
          children: _allDrawerItems,
        ),
    );
  }
}


