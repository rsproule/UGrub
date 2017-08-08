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
    this.user,
  });

  final GoogleSignInAccount user;
  final GridItemType type;

  @override
  _SideScrollListState createState() => new _SideScrollListState();
}

class _SideScrollListState extends State<SideScrollList> {
  DatabaseReference query;

  DatabaseReference _getQuery() {
    switch (widget.type) {
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

  int _getScore(int numFlags, DateTime date) {
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

  double _getDistance(String latitude, String longitude){
    Random r = new Random();
    return r.nextInt(25) / 5.0;
  }

  bool _filter(MyEvent event) {
    DateTime now = new DateTime.now();
    switch (widget.type) {
      case GridItemType.upcoming:
        return now.isAfter(event.date);
      case GridItemType.popular:
        int score = event.score;
        return now.isAfter(event.date) && score > 0;
      case GridItemType.nearby:
        //TODO check if the event is within x miles
        return now.isAfter(event.date);
      case GridItemType.none:
        return true;
      default:
        return false;
    }
  }

  Comparator _getSort(){
    Comparator time = (a, b) {
      DateTime aDate = DateTime.parse(a.value['date']);
      DateTime bDate =  DateTime.parse(b.value['date']);
      return bDate.difference(aDate).inMilliseconds;
    };

    Comparator score = (a, b) {
      Map aflags = a.value['flags'];
      int anumFlags = aflags != null ? aflags.length : 0;
      int a_Score = _getScore(anumFlags, DateTime.parse(a.value['date']));

      Map bflags = b.value['flags'];
      int bnumFlags = bflags != null ? bflags.length : 0;
      int b_Score = _getScore(bnumFlags, DateTime.parse(b.value['date']));

      return b_Score.compareTo(a_Score);
    };

    Comparator distance = (a, b) {

    };

    switch (widget.type) {
      case GridItemType.upcoming:
        return time;
      case GridItemType.popular:
        return score;
      case GridItemType.nearby:
      //TODO distance sort
        return time;
      case GridItemType.none:
        return time;
      default:
        return time;
    }
  }



  isFlagged(Map flags, GoogleSignInAccount user) {
    if(flags != null) {
      return flags.containsKey(user.id);
    }else return false;
  }


  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 200.0,
      child: new FirebaseAnimatedList(
        primary: true,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        defaultChild: new Center(child: new CircularProgressIndicator()),
        sort: _getSort(),
        query: _getQuery(),
        itemBuilder: (_, DataSnapshot snap, Animation<double> anim){
          String latitude;
          String longitude;
          if(snap.value['geolocation'] != null) {
            latitude = snap.value['geolocation']['latitude'];
            longitude = snap.value['geolocation']['longitude'];
          }

          Map flags = snap.value['flags'];
          int numFlags = flags != null ? flags.length : 0;
          MyEvent event = new MyEvent(
              key: snap.key,
              title: snap.value['title'],
              description: snap.value['description'],
              location: snap.value['location'],
              organization: snap.value['organization'],
              date: DateTime.parse(snap.value['date']),
              startTime: snap.value['startTime'],
              endTime: snap.value['endTime'],
              image: snap.value['image'],
              foodType: snap.value['foodType'],
              latitude: latitude,
              longitude: longitude,
              isFlagged: isFlagged(snap.value['flags'], widget.user),
              score: _getScore(numFlags, DateTime.parse(snap.value['date'])),
              distance: _getDistance(latitude, longitude)
          );

          if(_filter(event)){
            return new SideScrollItem(
              type: widget.type,
              event: event,
            );
          }else{
            return new Container();
          }

        },
      ),
    );
  }
}
