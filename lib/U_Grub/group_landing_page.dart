import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'groups.dart';
import 'group_info.dart';
import 'events.dart';

class GroupLandingPage extends StatefulWidget {
  const GroupLandingPage({
    this.group
  });

  final GroupItem group;


  @override
  _GroupLandingPageState createState() => new _GroupLandingPageState();
}

class _GroupLandingPageState extends State<GroupLandingPage> {
  @override
  Widget build(BuildContext context) {
    DatabaseReference query = FirebaseDatabase.instance.reference().child(
        "groups").child(widget.group.key).child("events");

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.group.name),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.info_outline),
                onPressed: () {
                  /* open the group info page */
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext build) {
                        return new GroupInfoPage(group: widget.group);
                      }
                  ));
                }
            )
          ],
        ),


        body: new EventFeed(query: query)
    );
  }
}
