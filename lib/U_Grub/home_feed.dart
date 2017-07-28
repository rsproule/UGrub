import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'events.dart';
import 'group_info.dart';
import 'category_tile.dart';
import 'drawer.dart';
import 'package:u_grub2/U_Grub/search.dart';

class HomePageFeed extends StatefulWidget {
  const HomePageFeed(
      {Key key, this.showDrawer, @required this.user, this.currentLocation, this.drawer})
      : super(key: key);

  final showDrawer;
  final GoogleSignInAccount user;
  final currentLocation;
  final AppDrawer drawer;

  @override
  _HomePageFeedState createState() => new _HomePageFeedState();
}

class _HomePageFeedState extends State<HomePageFeed> {

  static List<Widget> _popular_events = [];
  static List<Widget> _nearby_events = [];
  static List<Widget> _upcoming_events = [];
  static List<Widget> _food_categories = [];
  List<List<Widget>> allSideFeed = [
    _popular_events,
    _upcoming_events,
    _nearby_events,
    _food_categories
  ];

  buildAppBar() {
    TextStyle fontStyle = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).textTheme.subhead.copyWith(
            fontFamily: "Raleway",
            textBaseline: TextBaseline.alphabetic,
            color: Colors.black54)
        : Theme.of(context).textTheme.subhead;

    Widget appBar = new Card(
      child: new ListTile(
        title: new InkWell(
          child: new Center(
              child: new Text(
            "Search UGrub",
            style: fontStyle,
          )),
          onTap: _goToSearchView,
        ),
        trailing: new InkWell(
          child: new Icon(Icons.search),
          onTap: _goToSearchView,
        ),
      ),
    );

    return appBar;
  }



  buildHeader(String title) {
    TextStyle headerStyle = Theme
        .of(context)
        .textTheme
        .title
        .copyWith(color: Theme.of(context).accentColor);

    return new Container(
        padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
        child: new Row(
          children: <Widget>[
            new Text(
              title,
              style: headerStyle,
            ),
            new Expanded(child: new Container()),
            new Icon(Icons.arrow_right)
          ],
        ));
  }

  getSideScrollItems(
      DatabaseReference query, int index, GridItemType type) async {
    DataSnapshot snap = await query.once();
    Map b = snap.value;
    List<EventInSideScrollItem> _items = [];
    bool isPopular = (type == GridItemType.popular);

    b.forEach((k, snap) {
      MyEvent event = new MyEvent(
        key: k,
        title: snap['title'],
        description: snap['description'],
        location: snap['location'],
        organization: snap['organization'],
        date: DateTime.parse(snap['date']),
        startTime: snap['startTime'],
        endTime: snap['endTime'],
        image: snap['image'],
        foodType: snap['foodType'],
        latitude: snap['geolocation']['latitude'],
        longitude: snap['geolocation']['longitude'],

        isFlagged: isFlagged(snap['flags'], widget.user),
      );
      int score;
      if (isPopular) {
        score = _get_score(snap['flags'].length, event.date);
      }

      int distance;
      if (type == GridItemType.nearby) {
        double latitude = double.parse(snap['geolocation']['latitude']);
        double longitude = double.parse(snap['geolocation']['longitude']);
        distance = _get_distance(latitude, longitude, widget.currentLocation);
      }

      EventInSideScrollItem item = new EventInSideScrollItem(
        user: widget.user,
        event: event,
        score: isPopular ? score : null,
        daysTill: event.date.difference(new DateTime.now()).inDays,
        type: type,
        distance: distance,
      );
      _items.add(item);
    });

    Comparator time = (a, b) {
      DateTime aDate = a.event.date;
      DateTime bDate = b.event.date;
      return aDate.compareTo(bDate);
    };

    Comparator score = (a, b) {
      int a_Score = a.score;
      int b_Score = b.score;
      if (a_Score == b_Score) {
        DateTime aDate = a.event.date;
        DateTime bDate = b.event.date;
        return aDate.compareTo(bDate);
      } else {
        return b_Score.compareTo(a_Score);
      }
    };

    _items.sort(time);

    if (isPopular) {
      _items.sort(score);
    }
    _items.removeWhere((e) {
      DateTime now = new DateTime.now();

      return now.isAfter(e.event.date);
    });

    setState(() {
      allSideFeed[index] = _items;
    });
  }

  _get_score(int numFlags, DateTime date) {
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

  _get_distance(double latitude, double longitude, currentLocation) {
    return 5;
  }

  buildSideScroll(List<Widget> _items) {
    return new Container(
        height: 200.0,
        child: _items.length == 0
            ? new Center(child: new CircularProgressIndicator())
            : new ListView(
                scrollDirection: Axis.horizontal,
                primary: true,
                children: _items));
  }

  getFoodCategories(DatabaseReference query, int index) async {
    DataSnapshot snap = await query.once();
    Map b = snap.value;
    List<FoodTile> _items = [];

    TextStyle descriptionStyle =
        Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).textTheme.subhead.copyWith(
                fontFamily: "Raleway",
                textBaseline: TextBaseline.alphabetic,
                color: Colors.black54)
            : Theme.of(context).textTheme.subhead;

    b.forEach((k, v) {
      DatabaseReference query =
          FirebaseDatabase.instance.reference().child("categories").child(k);
      Map m = v;
      int count = m.length;

      Random r = new Random();
      List<MaterialColor> colors = Colors.primaries;
      Color randColor = colors.elementAt(r.nextInt(colors.length));
      String name = k;
      String initials = name.substring(0, 1);

      FoodTile _cat = new FoodTile(
        user: widget.user,
        name: name,
        image: new Container(
          color: randColor.withOpacity(.4),
          width: 50.0,
          height: 50.0,
          child: new CircleAvatar(
              child: new Text(
                initials,
                style: descriptionStyle,
              ),
              backgroundColor: randColor),
        ),
        count: count,
//        events: v,
        query: query,
      );
      _items.add(_cat);
    });
    Comparator count = (a, b) {
      return (b.count).compareTo(a.count);
    };

    _items.sort(count);

    setState(() {
      allSideFeed[index] = _items;
    });
  }

  @override
  void initState() {
    super.initState();

    //TODO edit the query here
    DatabaseReference popularEventsQuery =
        FirebaseDatabase.instance.reference().child("popular");
    getSideScrollItems(popularEventsQuery, 0, GridItemType.popular);

    DatabaseReference upcomingEventsQuery =
        FirebaseDatabase.instance.reference().child("popular");
    getSideScrollItems(upcomingEventsQuery, 1, GridItemType.upcoming);

    DatabaseReference nearbyEventsQuery =
        FirebaseDatabase.instance.reference().child("popular");
    getSideScrollItems(nearbyEventsQuery, 2, GridItemType.nearby);

    DatabaseReference foodTypesQuery =
        FirebaseDatabase.instance.reference().child("categories");
    getFoodCategories(foodTypesQuery, 3);
  }

  @override
  Widget build(BuildContext context) {
    final double systemTopPadding = MediaQuery.of(context).padding.top;

    Widget dynamicAppBar = new SliverAppBar(
      iconTheme: IconTheme.of(context),
      elevation: 0.0,
      flexibleSpace: new Container(
          padding:
              new EdgeInsets.only(top: systemTopPadding, left: 5.0, right: 5.0),
          child: buildAppBar()),
      backgroundColor: Colors.transparent,
      pinned: true,
    );
    final Orientation orientation = MediaQuery.of(context).orientation;

    Widget mainScreen = new CustomScrollView(slivers: <Widget>[
      dynamicAppBar,
      new SliverList(
          delegate: new SliverChildListDelegate(<Widget>[
        buildHeader("Popular Events:"),
        buildSideScroll(allSideFeed[0]),
        new Divider(),
        buildHeader("Upcoming Events:"),
        buildSideScroll(allSideFeed[1]),
        new Divider(),
        buildHeader("Nearby Events:"),
        buildSideScroll(allSideFeed[2]),
        new Divider(),
        buildHeader("Categories:"),
        new Divider(
          color: Colors.transparent,
        ),
        new GridView.count(
          shrinkWrap: true,
          primary: false,
          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          padding: const EdgeInsets.all(4.0),
          childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
          children: allSideFeed[3],
        )
      ])),
    ]);

    return new Scaffold(
      body: mainScreen,
      drawer: widget.drawer,
    );
  }

  void _goToSearchView() {
    Navigator.of(context).push(new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
          return new SearchPage();
        }, transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
          return new FadeTransition(opacity: animation, child: child);
        }));
  }

  isFlagged(Map flags, GoogleSignInAccount user) {
    if(flags != null) {
      return flags.containsKey(user.id);
    }else return false;
  }
}

class EventInSideScrollItem extends StatelessWidget {
  const EventInSideScrollItem({
    this.event,
    this.score,
    this.daysTill,
    this.type,
    this.distance,
    @required this.user
  });

  final MyEvent event;
  final int score;
  final GoogleSignInAccount user;
  final int daysTill;
  final int distance;
  final GridItemType type;

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.all(15.0),
        width: 200.0,
        child: new GridItem(
          user: user,
          event: event,
          score: score,
          daysTill: daysTill,
          type: type,
          distance: distance,
        ));
  }
}
