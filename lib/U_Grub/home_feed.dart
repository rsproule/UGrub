import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'events.dart';
import 'group_info.dart';

class HomePageFeed extends StatefulWidget {
  const HomePageFeed({Key key, this.showDrawer, this.user}) : super(key: key);

  final showDrawer;
  final GoogleSignInAccount user;

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
  List<List<Widget>> allSideFeed = [_popular_events, _upcoming_events ,_nearby_events, _food_categories];

  buildAppBar() {
    return new Card(
      child: new InkWell(
        onTap: _goToSearchView,
        child: new ListTile(
          title: new Text("Search UGrub"),
          leading: new IconButton(
              icon: new Icon(Icons.menu), onPressed: widget.showDrawer),
          trailing: new Icon(Icons.search),
        ),
      ),
    );
  }

  buildSearchBar() {
    return new Card(
      child: new ListTile(
        title: new Container(
          padding: const EdgeInsets.only(left: 35.0),
          child: new TextFormField(
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

  getSideScrollItems(DatabaseReference query, int index) async {
    DataSnapshot snap = await query.once();
    Map b = snap.value;
    List<EventInSideScrollItem> _items = [];

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
          isFlagged: false);

      EventInSideScrollItem item = new EventInSideScrollItem(
        event: event,
      );
      _items.add(item);
    });
    Comparator time = (a, b) {
      DateTime aDate = a.event.date;
      DateTime bDate = b.event.date;
      return aDate.compareTo(bDate);
    };

    _items.sort(time);


    _items.removeWhere((e){
      DateTime now = new DateTime.now();

      return now.isAfter(e.event.date);
    });

    setState(() {
      allSideFeed[index] = _items;
    });
  }

  buildSideScroll(List<Widget> _items) {
    return new Container(
        height: 200.0,
        child: _items.length == 0
            ? new Center(
                child: new IconButton(
                icon: new Icon(Icons.refresh),
                onPressed: () {
                  initState();
                },
              ))
            : new ListView(
                scrollDirection: Axis.horizontal,
                primary: true,
                children: _items));
  }

  getFoodCategories(DatabaseReference query, int index) async {
//    DataSnapshot snap = await query.once();
//    Map b = snap.value;
    List<FoodTile> _items = [];
//
//    b.forEach((k, snap) {
//      MyEvent event = new MyEvent(
//          title: snap['title'],
//          description: snap['description'],
//          location: snap['location'],
//          organization: snap['organization'],
//          date: DateTime.parse(snap['date']),
//          startTime: snap['startTime'],
//          endTime: snap['endTime'],
//          image: snap['image'],
//          foodType: snap['foodType'],
//          isFlagged: false);
//
//      EventInSideScrollItem item = new EventInSideScrollItem(
//        event: event,
//      );
//      _items.add(item);
//    });
//    Comparator time = (a, b) {
//      DateTime aDate = a.event.date;
//      DateTime bDate = b.event.date;
//      return aDate.compareTo(bDate);
//    };
//
//    _items.sort(time);
//
//
//    _items.removeWhere((e){
//      DateTime now = new DateTime.now();
//
//      return now.isAfter(e.event.date);
//    });

    Widget tacos = new FoodTile(
      image: "https://www.tacobueno.com/assets/food/tacos/Taco_BFT_Beef_990x725.jpg",
      name: "Tacos",
    );
    _items.add(tacos);

    Widget iceCream = new FoodTile(
      name: "Ice Cream",
      image: "https://www-tc.pbs.org/food/files/2012/07/History-of-Ice-Cream-1.jpg",
    );
    _items.add(iceCream);

    setState(() {
      allSideFeed[index] = _items;
    });
  }

  @override
  void initState() {
    super.initState();
    //TODO edit the query here
    DatabaseReference popularEventsQuery =
        FirebaseDatabase.instance.reference().child("events");
    getSideScrollItems(popularEventsQuery, 0);

    DatabaseReference upcomingEventsQuery =
        FirebaseDatabase.instance.reference().child("events");
    getSideScrollItems(upcomingEventsQuery, 1);

    DatabaseReference nearbyEventsQuery =
    FirebaseDatabase.instance.reference().child("events");
    getSideScrollItems(nearbyEventsQuery, 2);

    DatabaseReference foodTypesQuery =
    FirebaseDatabase.instance.reference().child("events");
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
      pinned: true,
    );
    final Orientation orientation = MediaQuery
        .of(context)
        .orientation;

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
        buildHeader("Food:"),
        new GridView.count(
          shrinkWrap: true,
          primary: false,
          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          padding: const EdgeInsets.all(4.0),
          childAspectRatio: (orientation == Orientation.portrait)
              ? 1.0
              : 1.3,
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
  const EventInSideScrollItem({this.event});

  final MyEvent event;

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.all(15.0),
        width: 200.0,
        child: new GridItem(
          event: event,
        ));
  }
}

class FoodTile extends StatelessWidget {
  const FoodTile({
    this.image,
    this.name
});

  final String image;
  final String name;
  @override
  Widget build(BuildContext context) {
    return new GridTile(
        child: new Image.network(image),
        footer: new GridTileBar(
          title: new Text(name),
          backgroundColor: Colors.black26,
        ),
    );
  }
}

