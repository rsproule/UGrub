import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'events.dart';
import 'group_info.dart';
import 'category_tile.dart';
import 'drawer.dart';
import 'SideScrollList.dart';
import 'search.dart';

class HomePageFeed extends StatefulWidget {
  const HomePageFeed(
      {Key key,
      this.showDrawer,
      @required this.user,
      this.currentLocation,
      this.drawer})
      : super(key: key);

  final showDrawer;
  final GoogleSignInAccount user;
  final currentLocation;
  final AppDrawer drawer;

  @override
  _HomePageFeedState createState() => new _HomePageFeedState();
}

class _HomePageFeedState extends State<HomePageFeed> {
  static List<MyEvent> _popular_events = [];
  bool popIsLoaded = false;
  static List<MyEvent> _nearby_events = [];
  bool upcIsLoaded = false;
  static List<MyEvent> _upcoming_events = [];
  bool nearbyIsLoaded = false;
  static List<Widget> _food_categories = [];

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
      _food_categories = _items;
    });
  }

  Widget buildFoodCategories(orientation) {
    return new GridView.count(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      padding: const EdgeInsets.all(4.0),
      childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
      children: _food_categories,
    );
  }

  loadInItems(GridItemType type){
    getItems(type, widget.user).then((List<MyEvent> events) {
      switch(type){
        case GridItemType.popular:
          setState((){
            _popular_events = events;
            popIsLoaded = true;
          });

          break;
        case GridItemType.upcoming:
          setState((){
            _upcoming_events = events;
            upcIsLoaded = true;
          });

          break;
        case GridItemType.nearby:
          setState((){
            _nearby_events = events;
            nearbyIsLoaded = true;
          });

          break;
        case GridItemType.none:
          //run for the hills
      }

    }).catchError((error){
      setState((){
        loader = new Container(
          height: 200.0,
          child: new Center(
            child: new Text("Error Loading Data")
          ),
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();

    loadInItems(GridItemType.popular);

    loadInItems(GridItemType.upcoming);

    loadInItems(GridItemType.nearby);

    startTimeout();


    //TODO get rid of this too
    DatabaseReference foodTypesQuery =
        FirebaseDatabase.instance.reference().child("categories");
    getFoodCategories(foodTypesQuery, 3);
  }

  startTimeout(){
    Duration timeout = new Duration(seconds: 5);

    return new Timer(timeout, handleTimeout);

  }

  reload(GridItemType type){
    setState((){
      loader = new Container(
        height: 200.0,
        child: new Center(
          child: new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: (){
                setState((){
                  loader =  new Container(
                    height: 200.0,
                    child: new Center(
                      child: new CircularProgressIndicator(),
                    ),
                  );
                });

                loadInItems(GridItemType.popular);
                startTimeout();
              }
          ),
        ),
      );
    });
  }

  handleTimeout()  {
    if(!popIsLoaded){
      reload(GridItemType.popular);
    }
    if(!upcIsLoaded){
      reload(GridItemType.upcoming);
    }
    if(!nearbyIsLoaded){
      reload(GridItemType.nearby);
    }
  }


  Widget loader = new Container(
    height: 200.0,
    child: new Center(
      child: new CircularProgressIndicator(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final double systemTopPadding = MediaQuery.of(context).padding.top;

    Widget popular = popIsLoaded
        ? new SideScrollList(
            type: GridItemType.popular, eventsInList: _popular_events, user: widget.user,)
        : loader;
    Widget upcomimg = upcIsLoaded
        ? new SideScrollList(
            type: GridItemType.upcoming, eventsInList: _upcoming_events, user: widget.user,)
        : loader;
    Widget nearby = nearbyIsLoaded
        ? new SideScrollList(
            type: GridItemType.nearby, eventsInList: _nearby_events, user: widget.user,)
        : loader;

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
        popular,
        new Divider(),
        buildHeader("Upcoming Events:"),
        upcomimg,
        new Divider(),
        buildHeader("Nearby Events:"),
        nearby,
        buildHeader("Categories:"),
        new Divider(
          color: Colors.transparent,
        ),
        buildFoodCategories(orientation)
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
          return new SearchPage(
            user: widget.user,
          );
        }, transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
          return new FadeTransition(opacity: animation, child: child);
        }));
  }
}
