import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'events.dart';
import 'groups.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'add_group.dart';
import 'drawer.dart';
import 'home_feed.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

class MainFeed extends StatefulWidget {
  const MainFeed(
      {Key key, this.currentLocation, this.showDrawer, this.user, this.drawer})
      : super(key: key);

  final showDrawer;
  final GoogleSignInAccount user;
  final currentLocation;
  final AppDrawer drawer;

  @override
  _MainFeedState createState() => new _MainFeedState();
}

class _MainFeedState extends State<MainFeed> with TickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>();

  int _index = 0;

  _showNotificationDialog(String title, String message) {
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: [
            new FlatButton(onPressed: (){
              Navigator.of(context).pop();
            },
                child: new Text("DISMISS", style: new TextStyle(color: Colors.red),)),
            new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _navigationViews[_index].controller.reverse();
                    _index = 2;
                    _navigationViews[_index].controller.forward();
                  });
                },
                child: new Text("VIEW")
            ),

          ],
        ));
  }

  setupNotifications(user) {
    final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        // TODO add message to db? or have the web service do that automatically
        // actually only the ones that come from the top maybe
        DatabaseReference ref = FirebaseDatabase.instance
            .reference()
            .child("users")
            .child(user.id)
            .child("notifications");

        Map msg = message['aps']['alert'];
        ref.push().set(
            {"title": msg['title'], "message": msg['body'], 'isOpened': false});
          _showNotificationDialog(msg['title'], msg['body']);
//        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        DatabaseReference ref = FirebaseDatabase.instance
            .reference()
            .child("users")
            .child(user.id)
            .child("notifications");

        Map msg = message['aps']['alert'];
        ref.push().set(
            {"title": msg['title'], "message": msg['body'], 'isOpened': false});
        _showNotificationDialog(msg['title'], msg['body']);
//        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) {
        DatabaseReference ref = FirebaseDatabase.instance
            .reference()
            .child("users")
            .child(user.id)
            .child("notifications");

        Map msg = message['aps']['alert'];
        ref.push().set(
            {"title": msg['title'], "message": msg['body'], 'isOpened': false});
        _showNotificationDialog(msg['title'], msg['body']);
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  List<NavigationView> _navigationViews;

  @override
  void initState() {
    super.initState();
    setupNotifications(widget.user);

    //flagged events query
    DatabaseReference query = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(widget.user.id)
        .child("flags");

    _navigationViews = <NavigationView>[
      new NavigationView(
          child: new HomePageFeed(
              user: widget.user,
              showDrawer: widget.showDrawer,
              drawer: widget.drawer,
              currentLocation: widget.currentLocation),
          vsync: this,
          icon: new Icon(Icons.home),
          title: new Text("Home"),
          color: Colors.blue),
      new NavigationView(
          child: new EventFeed(
            user: widget.user,
            query: query,
            showDrawer: widget.showDrawer,
            hasAppBar: true,
            title: "Flagged Events",
          ),
          vsync: this,
          icon: new Icon(Icons.flag),
          title: new Text("Flagged"),
          color: Colors.red),
      new NavigationView(
          child: new NotificationsPage(
              showDrawer: widget.showDrawer, user: widget.user),
          vsync: this,
          icon: new Icon(Icons.notifications),
          title: new Text("Notifications"),
          color: Colors.green),
      new NavigationView(
          child: new ProfilePage(
            showDrawer: widget.showDrawer,
            user: widget.user,
          ),
          vsync: this,
          icon: new Icon(Icons.person),
          title: new Text("User"),
          color: Colors.orange),
    ];

    for (NavigationView view in _navigationViews)
      view.controller.addListener(_rebuild);

    _navigationViews[_index].controller.value = 1.0;
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }

  @override
  void dispose() {
    for (NavigationView view in _navigationViews) view.controller.dispose();
    super.dispose();
  }

  Widget _buildTransitionsStack() {
    final List<FadeTransition> transitions = <FadeTransition>[];

    for (NavigationView view in _navigationViews)
      transitions.add(view.transition(BottomNavigationBarType.fixed, context));

    // We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.listenable;
      final Animation<double> bAnimation = b.listenable;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return new Stack(children: transitions);
  }

  @override
  Widget build(BuildContext context) {
    PageController _pageController = new PageController(
      initialPage: 0,
    );

//    Widget botNavBar = new BottomNavigationBar(
//      onTap: (int index) {
//        setState(() {
//          _navigationViews[_index].controller.reverse();
//          _index = index;
//          _navigationViews[_index].controller.forward();
//        });
//      },
//      items: <BottomNavigationBarItem>[
//        new BottomNavigationBarItem(
//            icon: new Icon(Icons.home),
//            title: _index == 0 ? new Text("Home") : new Text("")),
//        new BottomNavigationBarItem(
//            icon: new Icon(Icons.flag),
//            title: _index == 1 ? new Text("Flagged") : new Text("")),
//        new BottomNavigationBarItem(
//            icon: new Icon(Icons.notifications),
//            title: _index == 2 ? new Text("Notifications") : new Text("")),
//        new BottomNavigationBarItem(
//            icon: new Icon(Icons.person),
//            title: _index == 3 ? new Text("Extra") : new Text("")),
//      ],
//      currentIndex: _index,
//      type: BottomNavigationBarType.fixed,
//      iconSize: 27.0,
//    );

    final Widget botNavBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _index,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _navigationViews[_index].controller.reverse();
          _index = index;
          _navigationViews[_index].controller.forward();
        });
      },
    );

    return new Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: botNavBar,
        body: _buildTransitionsStack());
  }
}

addGroup(BuildContext context) {
  Navigator.of(context).push(new MaterialPageRoute<bool>(
      builder: (BuildContext build) {
        return new AddGroupForm();
      },
      fullscreenDialog: true));
}

class NavigationView {
  NavigationView({
    this.child,
    Widget icon,
    Widget title,
    Color color,
    TickerProvider vsync,
  })
      : _color = color,
        item = new BottomNavigationBarItem(
            icon: icon, title: title, backgroundColor: color),
        controller = new AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = new CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  final BottomNavigationBarItem item;
  final Widget child;
  final Color _color;
  final AnimationController controller;
  CurvedAnimation _animation;

  FadeTransition transition(
      BottomNavigationBarType type, BuildContext context) {
    Color iconColor;
    if (type == BottomNavigationBarType.shifting) {
      iconColor = _color;
    } else {
      final ThemeData themeData = Theme.of(context);
      iconColor = themeData.brightness == Brightness.light
          ? themeData.primaryColor
          : themeData.accentColor;
    }
    return new FadeTransition(opacity: _animation, child: child
//      new SlideTransition(
//          position: new FractionalOffsetTween(
//            begin: const FractionalOffset(0.0, 0.02),
//            // Small offset from the top.
//            end: FractionalOffset.topLeft,
//          )
//              .animate(_animation),
//          child: child
//      ),
        );
  }
}
