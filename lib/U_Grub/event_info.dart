import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'events.dart';
import 'package:google_sign_in/google_sign_in.dart';

class EventInfoPage extends StatefulWidget {
  const EventInfoPage({
    Key key,
    this.event,
    @required this.user
  }) : super(key: key);

  final MyEvent event;
  final GoogleSignInAccount user;

  @override
  _EventInfoPageState createState() => new _EventInfoPageState();
}

class _EventInfoPageState extends State<EventInfoPage> {
  bool isFlagged;

  Widget _bodyBuilder(BuildContext context) {
    MyEvent event = widget.event;
    isFlagged = widget.event.isFlagged;
    String flagCall = !isFlagged ? "Flag this Event" : "Unflag this Event";
    return new CustomScrollView(
      slivers: <Widget>[
        new SliverAppBar(

          actions: <Widget>[
            new PopupMenuButton(
                onSelected: (String selected) async {
                  if (selected == "Flag this Event") {
                    DatabaseReference flaggedEvents = FirebaseDatabase.instance
                        .reference()
                        .child("users").child(widget.user.id).child("flags");
                    DataSnapshot snap = await flaggedEvents.once();
                    Map m = snap.value;
                    bool actuallyIsFlagged = m.containsKey(widget.event.key);

                    //TODO Fix all of this garbage code i threw together before vaca
                    if (!actuallyIsFlagged) {
                      addEventToFlags(event, widget.user).then((bool success) {
                        _showScaffold(
                            context,
                            'You flagged this event.'
                        );
                        setState(() {
                          isFlagged = true;
                        });
                      });
                    }else{
                      setState((){
                        isFlagged = actuallyIsFlagged;
                      });
                    }
                  }
                  if(selected == "Unflag this Event") {

                    ///THIS CODE IS A PROBLEM I THINK---------------------------
                    DatabaseReference flaggedEvents = FirebaseDatabase.instance
                        .reference()
                        .child("users").child(widget.user.id).child("flags");
                    DataSnapshot snap = await flaggedEvents.once();
                    Map m = snap.value;
                    /// --------------------------------------------------------

                    bool actuallyIsFlagged = m.containsKey(widget.event.key);
                    if (actuallyIsFlagged) {
                      removeEventFromFlags(event, widget.user).then((
                          bool success) {
                        _showScaffold(context, "You unflagged this event.");
                        setState(() {
                          isFlagged = false;
                        });
                      });
                    }else{
                      setState((){
                        isFlagged = actuallyIsFlagged;
                      });
                    }
                  }
                },
                itemBuilder: (BuildContext context) =>
                <PopupMenuItem<String>>[
                  _buildMenuItem(Icons.map, "View in Map"),
                  _buildMenuItem(Icons.calendar_today, "Open in calendar"),
                  _buildMenuItem(Icons.share, "Share"),
                  _buildMenuItem(Icons.flag, flagCall)
                ]
            )
          ],
          expandedHeight: 256.0,
          pinned: true,
          flexibleSpace: new FlexibleSpaceBar(
            title: new Text(event.title),
            background: new Stack(
              fit: StackFit.expand,
              children: <Widget>[
                new Image.network(
                  event.image,
                  fit: BoxFit.cover,
                  height: 256.0,
                ),

                // This gradient ensures that the toolbar icons are distinct
                // against the background image.
                const DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: const LinearGradient(
                      begin: const FractionalOffset(0.5, 0.0),
                      end: const FractionalOffset(0.5, 0.30),
                      colors: const <Color>[
                        const Color(0x60000000), const Color(0x00000000)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        new SliverList(
            delegate: new SliverChildListDelegate(<Widget>[

              new About(
                user: widget.user,
                description: event.description,
                foodType: event.foodType,
                organization: event.organization,
              ),
              new Divider(),

              new DateTimeInfo(
                date: event.getDateString(),
                startsOn: event.startTime,
                endsOn: event.endTime,
              ),
              new Divider(),
              new Location(location: event.location,
                latitude: event.latitude,
                longitude: event.longitude,)


            ])
        )

      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Builder(
            builder: _bodyBuilder
        )
    );
  }

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

  void _showScaffold(BuildContext context, String s) {
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(s)
    ));
  }


}
Future<bool> addEventToFlags(MyEvent event, GoogleSignInAccount user) async {
  DatabaseReference currEventRef = FirebaseDatabase.instance.reference()
      .child('events')
      .child(event.key);
  DatabaseReference popEventRef = FirebaseDatabase.instance.reference().child(
      "popular").child(event.key);


  //TODO post to the current users flagged
  DatabaseReference usersFlags = FirebaseDatabase.instance.reference()
      .child("users").child(user.id).child("flags");

  //copy the event data snapshot to the users flagged
  currEventRef.once().then((DataSnapshot snap) async {
    usersFlags.child(event.key).set(snap.value).catchError((error) {
      return false;
    });
  });


  //TODO post to the events flagged

  currEventRef.child("flags").child(user.id).set({
    'name': user.displayName,
    'image': user.photoUrl
  }).catchError((error){
    return false;
  });

  popEventRef.child("flags").child(user.id).set({
    'name': user.displayName,
    'image': user.photoUrl
  }).catchError((error){
    return false;
  });

  return true;
}

Future<bool> removeEventFromFlags(MyEvent event, GoogleSignInAccount user) async {
  DatabaseReference currEventRef = FirebaseDatabase.instance.reference()
      .child('events')
      .child(event.key);
  DatabaseReference popEventRef = FirebaseDatabase.instance.reference().child(
      "popular").child(event.key);


  //TODO post to the current users flagged
  DatabaseReference usersFlags = FirebaseDatabase.instance.reference()
      .child("users").child(user.id).child("flags");

  //copy the event data snapshot to the users flagged
  currEventRef.once().then((DataSnapshot snap) async {
    await usersFlags.child(event.key).remove().catchError((error) {
      return false;
    });
  });


  //TODO post to the events flagged

  await currEventRef.child("flags").child(user.id).remove().catchError((error){
    return false;
  });

  await popEventRef.child("flags").child(user.id).remove().catchError((error){
    return false;
  });

  return true;
}

class About extends StatelessWidget {
  final String description;
  final String organization;
  final foodType;
  final GoogleSignInAccount user;

  const About({
    this.description,
    this.organization,
    this.foodType,
    @required this.user
  });


  @override
  Widget build(BuildContext context) {
    TextStyle descriptionStyle = Theme
        .of(context)
        .brightness == Brightness.light ? Theme
        .of(context)
        .textTheme
        .subhead
        .copyWith(
        fontFamily: "Raleway",
        textBaseline: TextBaseline.alphabetic,
        color: Colors.black54
    ) : Theme
        .of(context)
        .textTheme
        .subhead;

    Color color = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.black : Theme
        .of(context)
        .accentColor;


    Widget header = new Text("About",
        style: descriptionStyle.copyWith(color: color, fontSize: 28.0));
    Widget descrip = new Text("     " + description, style: descriptionStyle);

    Widget food = new Text(
      foodType.toString().replaceAll('[', "").replaceAll("]", ""),
      style: descriptionStyle,);
    if (foodType is String) {
      food = new CategoryTag(
          user: user,
          category: foodType.toString().replaceAll('[', ""),
          style: descriptionStyle, color: Theme
          .of(context)
          .accentColor);
    }
    else if (foodType is List) {
      List<Widget> _categories = [];
      for (String f in foodType) {
        Widget cat = new CategoryTag(
            user: user,
            category: f.replaceAll("[", "").replaceAll(",", "").replaceAll(
                "]", ""), style: descriptionStyle, color: Theme
            .of(context)
            .accentColor);
        _categories.add(cat);
      }
      List<Widget> formatted = [];
      int i = 0;
      while (i < _categories.length) {
        Widget tempRow = new Row(
          children: _categories.sublist(i, i + 2),
        );

        formatted.add(tempRow);
        i += 2;
      }

      food = new Column(
          children: formatted
      );
    }


    Widget org = new Row(children: <Widget>[
      new Icon(Icons.group, color: color,),
      new Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: new Text(organization, style: descriptionStyle),
      )

    ],);


    List<Widget> col = [
      header,
      new Divider(color: Colors.transparent, height: 6.0,),
      descrip,
      new Divider(color: Colors.transparent, height: 10.0,),
      org,
      new Divider(color: Colors.transparent, height: 4.0,),
      food
    ];

    return new Container(
      child: new Column(
        children: col, crossAxisAlignment: CrossAxisAlignment.start,),
      padding: const EdgeInsets.only(
          top: 30.0, bottom: 20.0, left: 25.0, right: 25.0),
    );
  }
}


class CategoryTag extends StatelessWidget {
  const CategoryTag({
    this.category,
    this.style,
    this.color,
    @required this.user
  });

  final GoogleSignInAccount user;
  final Color color;
  final TextStyle style;
  final String category;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.all(4.0),
      decoration: new BoxDecoration(
          borderRadius: const BorderRadius.all(
              const Radius.elliptical(30.0, 30.0)),
          color: color
      ),
      child: new InkWell(
//              splashColor: Colors.black45,
//              highlightColor: Colors.black12,
          onTap: () {
            DatabaseReference query = FirebaseDatabase.instance.reference()
                .child("categories")
                .child(category);
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext build) {
                  return new EventFeed(
                    query: query,
                    hasAppBar: true,
                    title: category,
                    user: user,);
                }
            )
            );
          },
          child: new Text(category, style: style,)
      ),

    );
  }
}

class DateTimeInfo extends StatelessWidget {
  const DateTimeInfo({
    Key key,
    this.date,
    this.startsOn,
    this.endsOn
  }) : super(key: key);

  final String date;
  final String startsOn;
  final String endsOn;


  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme
        .of(context)
        .brightness == Brightness.light ? Theme
        .of(context)
        .textTheme
        .subhead
        .copyWith(
        fontFamily: "Raleway",
        textBaseline: TextBaseline.alphabetic,
        color: Colors.black54
    ) : Theme
        .of(context)
        .textTheme
        .subhead;

    Color color = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.black : Theme
        .of(context)
        .accentColor;

    Widget header = new Text(
      "When", style: style.copyWith(color: color, fontSize: 28.0),);
    Widget dateWidget = new Text(date, style: style,);
    Widget timeWidget = new Text(startsOn + " - " + endsOn, style: style,);

    List<Widget> col = [
      header,
      new Divider(color: Colors.transparent, height: 6.0,),
      dateWidget,
      new Divider(color: Colors.transparent, height: 4.0,),
      timeWidget
    ];


    return new Container(
      child: new Column(
        children: col, crossAxisAlignment: CrossAxisAlignment.start,),
      padding: const EdgeInsets.only(
          top: 12.0, bottom: 20.0, left: 25.0, right: 25.0),
    );
  }
}

class Location extends StatelessWidget {
  const Location({
    Key key,
    @required this.location,
    @required this.latitude,
    @required this.longitude
  })
      : assert(location != null),
        super(key: key);

  final String location;
  final String latitude;
  final String longitude;

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme
        .of(context)
        .brightness == Brightness.light ? Theme
        .of(context)
        .textTheme
        .subhead
        .copyWith(
        fontFamily: "Raleway",
        textBaseline: TextBaseline.alphabetic,
        color: Colors.black54
    ) : Theme
        .of(context)
        .textTheme
        .subhead;

    Color color = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.black : Theme
        .of(context)
        .accentColor;

    Widget header = new Text(
      "Where", style: style.copyWith(color: color, fontSize: 28.0),);

    Widget loc = new Row(children: <Widget>[
      new Icon(Icons.location_on, color: color,),
      new Text("  " + location, style: style)
    ],);

    List<Widget> col = [
      header,
      new Divider(color: Colors.transparent, height: 6.0,),
      loc,
      new Divider(color: Colors.transparent, height: 16.0,),

      new Image.network(
          "https://maps.googleapis.com/maps/api/staticmap?center=${latitude},${longitude}&zoom=18&size=640x400&key=AIzaSyBEzlKe0AUBUVSINPeIniLv0PcEPACprPQ")

    ];

    return new Container(
      child: new Column(
        children: col, crossAxisAlignment: CrossAxisAlignment.start,),
      padding: const EdgeInsets.only(
          top: 12.0, bottom: 20.0, left: 25.0, right: 25.0),
    );
  }
}



