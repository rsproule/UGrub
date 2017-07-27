import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'events.dart';
import 'group_info.dart';

class HomePageFeed extends StatefulWidget {
  const HomePageFeed(
      {Key key, this.showDrawer, this.user, this.currentLocation})
      : super(key: key);

  final showDrawer;
  final GoogleSignInAccount user;
  final currentLocation;

  @override
  _HomePageFeedState createState() => new _HomePageFeedState();
}

class _HomePageFeedState extends State<HomePageFeed> {
  bool _isSearching = false;
  TextEditingController _searchQuery = new TextEditingController();

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
    return new Card(
      child: new ListTile(
        title: new InkWell(
          child: new Text("Search UGrub"),
          onTap: _goToSearchView,
        ),
        leading: new IconButton(
            icon: new Icon(Icons.menu), onPressed: widget.showDrawer),
        trailing: new InkWell(
          child: new Icon(Icons.search),
          onTap: _goToSearchView,
        ),
      ),
    );
  }

  buildSearchBar() {
    return new Card(
      child: new ListTile(
        title: new Container(
          padding: const EdgeInsets.only(left: 35.0),
          child: new TextField(
            onSubmitted: (val) {
              if (val == "") {
                // Just exits the search view when there is nothing there
                Navigator.of(context).pop();
              }
            },
            keyboardType: TextInputType.text,
            autofocus: true,
            controller: _searchQuery,
            decoration: new InputDecoration(
              isDense: true,
              hintText: "Search",
              hideDivider: true,
            ),
            style: Theme.of(context).textTheme.title,
          ),
        ),
      ),
    );
  }

  buildHeader(String title) {
    TextStyle headerStyle = Theme
        .of(context)
        .textTheme
        .title
        .copyWith(color: Theme.of(context).accentColor);

    return new Container(
        padding: const EdgeInsets.only(top: 10.0),
        child: new Center(
          child: new Text(
            title,
            style: headerStyle,
          ),
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
        title: snap['title'],
        description: snap['description'],
        location: snap['location'],
        organization: snap['organization'],
        date: DateTime.parse(snap['date']),
        startTime: snap['startTime'],
        endTime: snap['endTime'],
        image: snap['image'],
        foodType: snap['foodType'],
        isFlagged: false,
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

    b.forEach((k, v) {
      DatabaseReference query = FirebaseDatabase.instance.reference().child("categories").child(k);
      Map m = v;
      int count = m.length;

      FoodTile _cat = new FoodTile(

        name: k,
        image: new Container(),
        count: count,
//        events: v,
        query: query,

      );
      _items.add(_cat);
    });

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
          child: _isSearching ? buildSearchBar() : buildAppBar()),
      backgroundColor: Colors.transparent,
      snap: false,
      floating: true,
    );
    final Orientation orientation = MediaQuery.of(context).orientation;

    return new CustomScrollView(slivers: <Widget>[
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
  }

  void _goToSearchView() {
    ModalRoute.of(context).addLocalHistoryEntry(new LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _isSearching = false;
          _searchQuery.clear();
        });
      },
    ));
    setState(() {
      _isSearching = true;
    });
  }
}

class EventInSideScrollItem extends StatelessWidget {
  const EventInSideScrollItem(
      {this.event, this.score, this.daysTill, this.type, this.distance});

  final MyEvent event;
  final int score;
  final int daysTill;
  final int distance;
  final GridItemType type;



  @override
  Widget build(BuildContext context) {


    return new Container(
        padding: const EdgeInsets.all(15.0),
        width: 200.0,
        child: new GridItem(
          event: event,
          score: score,
          daysTill: daysTill,
          type: type,
          distance: distance,
        ));
  }
}

class FoodTile extends StatelessWidget {
  const FoodTile({
    this.image,
    this.name,
    this.events,
    this.query,
    this.count
  });

  final Widget image;
  final String name;
  final int count;
  final List<MyEvent> events;
  final DatabaseReference query;

  @override
  Widget build(BuildContext context) {
    _buildLeadingWidget(String val, IconData icon) {
      return new Row(
        children: <Widget>[
          new Expanded(child: new Container()),
          new Container(
            color: Colors.black45,
            padding: const EdgeInsets.all(4.0),
            child: new Row(
                children: <Widget>[
                  new Container(padding: const EdgeInsets.only(right: 5.0),
                      child: new Icon(icon)
                  ),
                  new Text(val, style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white),),

                ]),
          ),

        ],

      );
    }

    return new GestureDetector(
      onTap: (){
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext build) {
              return new EventFeed(query: query, hasAppBar: true, title: name,);
            }
        )
        );
      },
      child: new GridTile(

        child: new FittedBox(
          fit: BoxFit.fill,
          child: image,
        ),
        footer: new GridTileBar(
          title: new Text(name),
          backgroundColor: Colors.black26,
        ),
        header: _buildLeadingWidget(count.toString(), Icons.event),
      ),
    );
  }
}
