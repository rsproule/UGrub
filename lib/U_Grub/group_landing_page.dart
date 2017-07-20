import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'groups.dart';
import 'group_info.dart';
import 'events.dart';
import 'user.dart';

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

    final String numMembers = widget.group.admins.length.toString() + " Admin" + (widget.group.admins.length==1 ? "": "s");
    Widget memberHeader = new Container(
      padding: const EdgeInsets.all(10.0),
      child: new Text(numMembers+ ":", style: Theme.of(context).textTheme.subhead,),
    );
    List<Widget> _memberTiles = [memberHeader, new Divider()];

    for (User m in widget.group.admins){
      _memberTiles.add(new MemberTile(member: m,));
    }

    Widget adminsButton = new IconButton(
      onPressed: (){
        showDialog(
            context: context,
            child: new Dialog(
              child: new Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: new ListView(
                  children: _memberTiles,
                  shrinkWrap: true,
                ),
              ),
            )
        );
      },
      icon: new Icon(Icons.assignment_ind),
    );

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.group.name),
          actions: <Widget>[
            adminsButton,
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
            ),

          ],
        ),


        body: new EventFeed(query: query)
    );
  }
}
