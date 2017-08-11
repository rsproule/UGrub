import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'SideScroll.dart';
import 'events.dart';
import 'group_info.dart';

class SideScrollList extends StatefulWidget {
  const SideScrollList({
    @required this.type,
    @required this.eventsInList,
    @required this.user,
  });


  final List eventsInList;
  final GoogleSignInAccount user;
  final GridItemType type;

  @override
  _SideScrollListState createState() => new _SideScrollListState();
}

class _SideScrollListState extends State<SideScrollList> {

  Widget buildList(List<MyEvent> items) {
    List<Widget> sideScrollTiles = [];

    items.forEach((MyEvent e) {
      sideScrollTiles.add(new SideScrollItem(
        user: widget.user,
        type: widget.type,
        event: e,
      ));
    });

    return new ListView(
      scrollDirection: Axis.horizontal,
      children: sideScrollTiles,
    );
  }

  Widget buildLoading() {
    return new Center(
      child: new Container(child: new CircularProgressIndicator()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 200.0,

        //TODO dont use firebase list because it causes very chunky scrolling
        child: buildList(widget.eventsInList)
//
// new FirebaseAnimatedList(
//        primary: true,
//        scrollDirection: Axis.horizontal,
//        shrinkWrap: true,
//        defaultChild: new Center(child: new CircularProgressIndicator()),
//        sort: _getSort(),
//        query: _getQuery(),
//        itemBuilder: (_, DataSnapshot snap, Animation<double> anim){
//          if(_cache.containsKey(snap.key)){
//            if(_filter(_cache[snap.key].event)) {
//              return _cache[snap.key];
//            }
//            else{
//              return new Container();
//            }
//          }
//          else {
//            String latitude;
//            String longitude;
//            if (snap.value['geolocation'] != null) {
//              latitude = snap.value['geolocation']['latitude'];
//              longitude = snap.value['geolocation']['longitude'];
//            }
//
//            Map flags = snap.value['flags'];
//            int numFlags = flags != null ? flags.length : 0;
//            MyEvent event = new MyEvent(
//                key: snap.key,
//                title: snap.value['title'],
//                description: snap.value['description'],
//                location: snap.value['location'],
//                organization: snap.value['organization'],
//                date: DateTime.parse(snap.value['date']),
//                startTime: snap.value['startTime'],
//                endTime: snap.value['endTime'],
//                image: snap.value['image'],
//                foodType: snap.value['foodType'],
//                latitude: latitude,
//                longitude: longitude,
//                isFlagged: isFlagged(snap.value['flags'], widget.user),
//                score: _getScore(numFlags, DateTime.parse(snap.value['date'])),
//                distance: _getDistance(latitude, longitude)
//            );
//
//            _cache.putIfAbsent(snap.key, () => new SideScrollItem(
//              type: widget.type,
//              event: event,
//            ));
//
//            if(_filter(event)){
//              return new SideScrollItem(
//                type: widget.type,
//                event: event,
//              );
//            }else{
//              return new Container();
//            }
//          }
//
//        },
//      ),
        );
  }
}

Future<List<MyEvent>> getItems(GridItemType type, GoogleSignInAccount user) async {
  List<MyEvent> items = [];
  DatabaseReference query = getQuery(type);
  Comparator sort = getSort(type);

  DataSnapshot snap = await query.once();

  Map results = snap.value;
  results.forEach((k, v) {
    MyEvent event = getEvent(k, v, user);

    if (filter(type, event)) {
      items.add(event);
    }
  });

  items.sort(sort);

  return items;
}

Comparator getSort(GridItemType type) {
  Comparator time = (MyEvent a, MyEvent b) {
    return a.date.difference(b.date).inMilliseconds;
  };

  Comparator score = (MyEvent a, MyEvent b) {
    return b.score.compareTo(a.score);
  };

//    TODO distance sort
//    Comparator distance = (a, b) {
//
//    };

  switch (type) {
    case GridItemType.upcoming:
      return time;
    case GridItemType.popular:
      return score;
    case GridItemType.nearby:
      return time;
    case GridItemType.none:
      return time;
    default:
      return time;
  }
}
DatabaseReference getQuery(GridItemType type) {
  switch (type) {
    case GridItemType.upcoming:
      return FirebaseDatabase.instance.reference().child("events");
    case GridItemType.popular:
      return FirebaseDatabase.instance.reference().child("popular");
    case GridItemType.nearby:
      return FirebaseDatabase.instance.reference().child("events");
    case GridItemType.none:
      return FirebaseDatabase.instance.reference().child("events");
    default:
      return FirebaseDatabase.instance.reference().child("events");
  }
}

bool filter(GridItemType type, MyEvent event) {
  DateTime now = new DateTime.now();
  switch (type) {
    case GridItemType.upcoming:
      return !now.isAfter(event.date);
    case GridItemType.popular:
      int score = event.score;
      return !now.isAfter(event.date) && score > 0;
    case GridItemType.nearby:
    //TODO check if the event is within x miles
      return !now.isAfter(event.date);
    case GridItemType.none:
      return true;
    default:
      return false;
  }
}

MyEvent getEvent(String key, Map snap, GoogleSignInAccount user) {
  String latitude;
  String longitude;
  if (snap['geolocation'] != null) {
    latitude = snap['geolocation']['latitude'];
    longitude = snap['geolocation']['longitude'];
  }

  Map flags = snap['flags'];
  int numFlags = flags != null ? flags.length : 0;

  MyEvent event = new MyEvent(
      key: key,
      title: snap['title'],
      description: snap['description'],
      location: snap['location'],
      organization: snap['organization'],
      date: DateTime.parse(snap['date']),
      startTime: snap['startTime'],
      endTime: snap['endTime'],
      image: snap['image'],
      foodType: snap['foodType'],
      latitude: latitude,
      longitude: longitude,
      isFlagged: isFlagged(snap['flags'], user),
      score: getScore(numFlags, DateTime.parse(snap['date'])),
      distance: getDistance(latitude, longitude));

  return event;
}


int getScore(int numFlags, DateTime date) {
  int score;
  int dateBonus;
  int hoursTillEvent = date.difference(new DateTime.now()).inHours;
  dateBonus = -hoursTillEvent;
  score = 10 * numFlags + dateBonus;
  if (score < 0) {
    score = numFlags;
  }
  return score;
}

double getDistance(String latitude, String longitude) {
  Random r = new Random();
  return r.nextInt(25) / 5.0;
}




isFlagged(Map flags, GoogleSignInAccount user) {
  if (flags != null) {
    return flags.containsKey(user.id);
  } else
    return false;
}