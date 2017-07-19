import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'group_info.dart';
import 'events.dart';
import 'group_landing_page.dart';
import 'user.dart';


class GroupFeed extends StatefulWidget {
  const GroupFeed({
    Key key,

  }) : super(key: key);

  @override
  _GroupFeedState createState() => new _GroupFeedState();
}

class FirebaseGroupDecoder extends Converter<DataSnapshot, GroupItem> {
  const FirebaseGroupDecoder();

  @override
  GroupItem convert(DataSnapshot snap) {
    Map input = snap.value;
    Map m = input['members'];

    List<User> _members = [];

    m.forEach((k, v) {
      _members.add(
          new User(
              name: v['name'],
              image: v['image'],
              Id: k
          )
      );
    });

    Map ev = input['events'];

    List<MyEvent> _events = [];

    if(ev != null) {
      ev.forEach((k, v) {
        _events.add(
            new MyEvent(
                title: v['title'],
                description: v['description'],
                location: v['location'],
                organization: v['organization'],
                date: DateTime.parse(v['date']),
                startTime: v['startTime'],
                endTime: v['endTime'],
                image: v['image'],
                foodType: v['foodType'],
                isFlagged: false
            )
        );
      });
    }

    Image thumbnail = input['thumbnail'] != null ? new Image.network(
      input['thumbnail'], fit: BoxFit.fill, width: 120.0, height: 120.0,) : null;

    return new GroupItem(
        name: input['name'],
        key: snap.key,
        description: input['description'],
        image: input['image'],
        members: _members,
        contactInfo: new ContactInfo(
            email: input['contactInfo']['email'] == null ? "Not Listed" : input['contactInfo']['email'],
            phoneNumber: input['contactInfo']['phone'] == null ? "None Listed" : input['contactInfo']['phone']
        ),
        events: _events,
        imgFile: new Image.network(input['image']),
        thumbnail: thumbnail

    );
  }
}

class _GroupFeedState extends State<GroupFeed> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();


  PopupMenuItem<String> _buildMenuItem(IconData icon, String label) {
    Color color = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.black : Theme
        .of(context)
        .accentColor;
    return new PopupMenuItem<String>(
      value: label,
      child: new Row(
        children: <Widget>[
          new Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: new Icon(icon, color: color)
          ),
          new Text(label),
        ],
      ),
    );
  }

  Widget buildGroupItem(GroupItem item) {
    ThemeData theme = Theme.of(context);
    String groupName = item.name;

    Widget nonDismissibleGroup = new Container(
      child: new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(
                "$groupName", style: new TextStyle(color: theme.accentColor),),
              subtitle: new Text(item.description),
              leading: item.thumbnail != null
                  ? new FittedBox(
                    fit: BoxFit.cover,
                    child: item.thumbnail
              )
                  : new Icon(Icons.group),
              dense: true,
              trailing: new PopupMenuButton(
                onSelected: (String selected) {
                  switch (selected) {
                    case "Leave":
                      _scaffoldKey.currentState.showSnackBar(
                          new SnackBar(
                              content: new Text("You have left $groupName")));
                      break;
                    case "Mute":
                      _scaffoldKey.currentState.showSnackBar(
                          new SnackBar(
                              content: new Text("You have muted $groupName")));
                      break;
                    case "Hide":
                      _scaffoldKey.currentState.showSnackBar(
                          new SnackBar(
                              content: new Text("You have hidden $groupName")));
                      break;
                  }
                },
                itemBuilder: (BuildContext context) =>
                <PopupMenuItem<String>>[
                  _buildMenuItem(Icons.exit_to_app, "Leave"),
                  _buildMenuItem(Icons.volume_mute, "Mute"),
                  _buildMenuItem(Icons.blur_off, "Hide")
                ],
                tooltip: "Show group options",

              ),
              onTap: () {
                /*open the group landing page*/
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext build) {
                      return new GroupLandingPage(group: item);
                    }
                ));
              },
              onLongPress: () {
                /* open the group info page */
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext build) {
                      return new GroupInfoPage(group: item);
                    }
                ));
              },

              //notification indicator
//              leading: new Icon(Icons.notifications, color: theme.accentColor),
            ),
            new Divider(height: 0.0,)
          ]
      ),
    );

    //dismissible version:
//    Widget groupItem = new Column(
//        children: <Widget>[new Dismissible(
//          key: new ObjectKey(item),
//          child: new ListTile(
//            title: new Text("$groupName"),
//            subtitle: new Text(item.description),
//            onTap: () {
//              /*open the group page*/
//              Navigator.of(context).push(new MaterialPageRoute(
//                  builder: (BuildContext build) {
//                    return new GroupInfoPage(group: item);
//                  }
//              ));
//            },
//            onLongPress: () {
//              /* show options for the group ie delete, view,  */
//            },
//          ),
//          background: new Container(
//            color: Colors.red,
//            child: new ListTile(
//              leading: new Icon(Icons.exit_to_app),
//            ),
//          ),
//          direction: DismissDirection.startToEnd,
//          onDismissed: (DismissDirection d) {
////        setState(() {
////          _groupItems.remove(item);
////        });
//            Future<bool> confirmDelete = showDialog<bool>(
//                context: context,
//                child: new AlertDialog(
//                  title: new Text("Are you sure you want to leave $groupName?"),
//                  actions: <Widget>[
//                    new FlatButton(
//                        child: const Text('CANCEL'),
//                        onPressed: () {
//                          Navigator.pop(context, false);
//                        }
//                    ),
//                    new FlatButton(
//                        child: const Text(
//                          'LEAVE', style: const TextStyle(color: Colors.red),),
//                        onPressed: () {
//                          Navigator.pop(context, true);
//                        }
//                    )
//                  ],
//                )
//            ).then<bool>((isConfirmed) {
//              // Todo also delete from the DB... remove this user from that group
//
//              if (isConfirmed) {
//                _scaffoldKey.currentState.showSnackBar(new SnackBar(
//                    content: new Text("You have left $groupName")
//                )
//                );
//              }
//              else {
////              final int insertionIndex = lowerBound(_groupItems, item);
//                setState(() {
////                _groupItems.insert(insertionIndex, item);
//                  ref = FirebaseDatabase.instance.reference().child(
//                      'groups');
//                });
//              }
//            });
//          },
//        ),
//        new Divider(height: 0.0,)
//        ]
//    );
    return nonDismissibleGroup;
  }


//  @override
//  initState() {
//    super.initState();
//    _initGroups();
//  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(message)
    ));
  }

  Map<String, GroupItem> _groupCache = new Map();
  DatabaseReference ref = FirebaseDatabase.instance.reference().child(
      'groups');

  @override
  Widget build(BuildContext context) {
    final decoder = new FirebaseGroupDecoder();
    return new Scaffold(
        key: _scaffoldKey,
        body: new FirebaseAnimatedList(
            query: ref,
            itemBuilder: (context, DataSnapshot snap,
                Animation<double> animation) {
              //cache logic
              if (_groupCache.containsKey(snap.key)) {
                return buildGroupItem(_groupCache[snap.key]);
              } else {
                GroupItem gi = decoder.convert(snap);
                _groupCache.putIfAbsent(snap.key, () => gi);
                return buildGroupItem(gi);
              }
            }
        )
    );
  }
}

class GroupItem implements Comparable<GroupItem> {
  GroupItem({
    @required this.name,
    @required this.key,
    @required this.description,
    @required this.image,
    this.members,
    this.contactInfo,
    this.events,
    this.imgFile,
    this.thumbnail
  })
      : assert(name != null),
        assert(description != null),
        assert(image != null);

  GroupItem.from(GroupItem item)
      : name = item.name,
        key = item.key,
        description = item.description,
        image = item.image,
        members = item.members,
        contactInfo = item.contactInfo,
        events = item.events,
        thumbnail = item.thumbnail,
        imgFile = item.imgFile;

  final String name;
  final String key;
  final String description;
  final String image;
  final List<User> members;
  final ContactInfo contactInfo;
  final List<MyEvent> events;

  final Image imgFile;
  final Image thumbnail;


  @override
  int compareTo(GroupItem other) => name.compareTo(other.name);
}
