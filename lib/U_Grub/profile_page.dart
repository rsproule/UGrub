import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';
import 'package:u_grub2/U_Grub/events.dart';
import 'package:u_grub2/U_Grub/groups.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key key,
    this.showDrawer,
    @required this.user
  }) : super(key: key);

  final GoogleSignInAccount user;
  final showDrawer;

  @override
  _ProfilePageState createState() => new _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  @override
  Widget build(BuildContext context) {
    List<Widget> _tiles = [
      new ListTile(
        title: new Text("Groups"),
        trailing: new Icon(Icons.keyboard_arrow_right),
        leading: new Icon(Icons.group),
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext build) {
                return new GroupFeed(user: widget.user,);
              }
          ));
        },

      ),
      new Divider(height: 0.0,),
      new ListTile(
        title: new Text("Saved"),
        trailing: new Icon(Icons.keyboard_arrow_right),
        leading: new Icon(Icons.bookmark),
        onTap: () {
          DatabaseReference query = FirebaseDatabase.instance
              .reference()
              .child("users")
              .child(widget.user.id).child("flags");
          Navigator
              .of(context)
              .push(new MaterialPageRoute(
              builder: (BuildContext build) {
                return new EventFeed(
                  user: widget.user, title: "Saved Events", query:query, hasAppBar: true,);
              }
          ));
        },

      ),
      new Divider(height: 0.0,)

    ];


    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: widget.showDrawer
        ),
        title: new Text(widget.user.displayName),
      ),
      body: new ListView(
          children: _tiles
      ),

    );
  }
}
