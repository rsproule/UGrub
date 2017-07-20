import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:firebase_database/firebase_database.dart";
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'event_info.dart';
import 'groups.dart';

class EventFeed extends StatefulWidget {
  const EventFeed({
    Key key,
    @required this.query

  }) : super(key: key);

  final DatabaseReference query;

  @override
  _EventFeedState createState() => new _EventFeedState();
}

class _EventFeedState extends State<EventFeed> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<
      RefreshIndicatorState>();
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();


  Comparator time = (a, b) {
    DateTime adate = DateTime.parse(a.value['date']);
    DateTime bdate = DateTime.parse(b.value['date']);
    return adate.compareTo(bdate);
  };

  @override
  Widget build(BuildContext context) {
    Widget mainFeed = new FirebaseAnimatedList(
        defaultChild: new Center(child: new Text("Nother here yet"),),
        sort: time,
        query: widget.query,
        itemBuilder: (context, DataSnapshot snap, Animation<double> animation) {
          MyEvent event = new MyEvent(
              title: snap.value['title'],
              description: snap.value['description'],
              location: snap.value['location'],
              organization: snap.value['organization'],
              date: DateTime.parse(snap.value['date']),
              startTime: snap.value['startTime'],
              endTime: snap.value['endTime'],
              image: snap.value['image'],
              foodType: snap.value['foodType'],
              isFlagged: false
          );


          return new EventCard(
            event: event,
            height: 366.0,
          );
        }
    );

    return new Scaffold(
        key: _scaffoldKey,
        body: new RefreshIndicator(
            key: _refreshIndicatorKey,
            child: mainFeed,
            onRefresh: _handleRefresh
        )
    );
  }


  Future<Null> _handleRefresh() {
    // TODO make this actually refresh not just set a timer
    final Completer<Null> completer = new Completer<Null>();
    new Timer(const Duration(seconds: 1), () {
      completer.complete(null);
    });
    return completer.future.then((context) {
      _scaffoldKey.currentState?.showSnackBar(new SnackBar(
          content: const Text("Refresh complete"),
          action: new SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              }
          )
      ));
    });
  }
}

class DateDivider extends StatelessWidget {
  const DateDivider({
    Key key,
    this.date
  }) : super(key: key);

  final String date;


  @override
  Widget build(BuildContext context) {
    Widget dateDivider = new Container(
      padding: const EdgeInsets.all(2.0),
      color: Colors.black12,
      width: 10.0,
      alignment: FractionalOffset.center,
      child: new Text("$date"),
    );

    return dateDivider;
  }
}


class MyEvent {
  const MyEvent({
    @required this.title,
    @required this.description,
    @required this.location,
    @required this.organization,
    @required this.date,
    @required this.startTime,
    @required this.endTime,
    @required this.image,
    @required this.foodType,
    @required this.isFlagged
  })
      : assert(title != null),
        assert(description != null),
        assert(location != null),
        assert(organization != null),
        assert(date != null),
        assert(startTime != null),
        assert(endTime != null),
        assert(image != null),
        assert(isFlagged != null),
        assert(foodType != null);

  final String title;
  final String description;
  final String organization;
  final String foodType;
  final String location;
  final String image;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isFlagged;

  String getDateString() {
    DateTime d = this.date;

    String date = getMonth(d.month) + " " + d.day.toString() + ", " +
        d.year.toString();

    return date;
  }

  String getMonth(int m) {
    List months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      'July',
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    return months[m - 1];
  }
}


class EventCard extends StatelessWidget {
  const EventCard({
    @required this.event,
    @required this.height
  });

  final MyEvent event;
  final double height;


  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme
        .of(context)
        .textTheme
        .title;
    final TextStyle descriptionTheme = Theme
        .of(context)
        .textTheme
        .subhead;

    Widget card = new Container(
      padding: const EdgeInsets.all(16.0),
      height: height,
      child: new Card(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new SizedBox(
                height: height / 2,
                child: new Stack(
                  children: <Widget>[
                    new Positioned.fill(
                      child: new Image.network(
                        event.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    new Positioned(
                      bottom: 6.0,
                      left: 16.0,
                      right: 16.0,
                      child: new FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: FractionalOffset.centerLeft,
                        child: new Text(event.title,
                            style: titleStyle.copyWith(color: Colors.white)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: new DefaultTextStyle(
                    overflow: TextOverflow.ellipsis,
                    style: descriptionTheme,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // three line description
                        new Flexible(
                          child: new Container(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: new Text(
                              event.description,
                              style: descriptionTheme.copyWith(
                                  color: Colors.black54),
                            ),
                          ),
                        ),

                        new Text(event.organization),
                        new Text(
                            event.getDateString() + " @ " + event.startTime),
                      ],
                    ),
                  ),
                ),
              ),
              new ButtonTheme.bar(
                child: new ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new PopupMenuButton(
                        child: new FlatButton(
                          child: const Text('SHARE'),
                          textColor: Colors.amber.shade500,
                          onPressed: () {}
                        ),
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuItem<String>>[
                          buildMenuItem(context, Icons.replay, "Repost"),
                          buildMenuItem(context, Icons.perm_media, "Share"),
                        ]
                    ),
                    new FlatButton(
                      child: const Text('MORE INFO'),
                      textColor: Colors.amber.shade500,
                      onPressed: () {
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext build) {
                              return new EventInfoPage(event: event,);
                            }
                        )
                        );
                      },
                    ),
                  ],
                ),
              ),
            ]
        ),

      ),

    );

    return card;
  }
}






