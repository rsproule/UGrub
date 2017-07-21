import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    Key key,
    this.user,
    this.showDrawer
}) : super(key : key);

  final GoogleSignInAccount user;
  final showDrawer;
  @override
  _NotificationsPageState createState() => new _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: widget.showDrawer
        ),
        title: new Text("Notifications"),
      ),
    );

  }
}
