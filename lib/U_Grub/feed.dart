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
  const MainFeed({
    Key key,
    this.currentLocation,
    this.showDrawer,
    this.user,
    this.drawer

  }) : super(key: key);

  final showDrawer;
  final GoogleSignInAccount user;
  final currentLocation;
  final AppDrawer drawer;

  @override
  _MainFeedState createState() => new _MainFeedState();
}

class _MainFeedState extends State<MainFeed> with TickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();

  int _index = 0;

  setupNotifications(user){
    final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        // TODO add message to db? or have the web service do that automatically
        // actually only the ones that come from the top maybe
        DatabaseReference ref = FirebaseDatabase.instance.reference().child("users").child(user.id).child(
            "notifications");

        Map msg = message['aps']['alert'];
        print(msg);
        ref.push().set({
          "title" : msg['title'],
          "message" : msg['body'],
          'isOpened' : false
        });

//        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
        setState((){
          _index = 2;
        });


//        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: $message");
        setState((){
          _index = 2;
        });
//        _navigateToItemDetail(message);
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true)
    );

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }


  @override
  void initState() {
    super.initState();
    setupNotifications(widget.user);
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    PageController _pageController = new PageController(
      initialPage: 0,


    );

    Widget botNavBar = new BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            _index = index;
//            _pageController.animateToPage(
//                index, duration: const Duration(seconds: 1),
//                curve: Curves.linear,
//
//            );
          _pageController.jumpToPage(index);

          });
        },
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: new Icon(Icons.home), title: _index == 0 ? new Text("Home") : new Text("")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.flag), title: _index == 1 ? new Text("Flagged") : new Text("")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.notifications), title: _index == 2 ? new Text("Notifications") : new Text("")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.person), title: _index == 3 ? new Text("Extra") : new Text("")),
        ],
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        iconSize: 27.0,


    );

    //all events query
    DatabaseReference query = FirebaseDatabase.instance.reference().child(
        'users').child(widget.user.id).child("flags");


    List<Widget> _views = [
//        new Container(
//            child: new GroupFeed(),
//            padding: const EdgeInsets.only(top: 10.0),
//        ),

      new HomePageFeed(user: widget.user, showDrawer: widget.showDrawer, drawer: widget.drawer, currentLocation : widget.currentLocation),
      new EventFeed(user: widget.user, query: query, showDrawer: widget.showDrawer, hasAppBar: true, title: "Flagged Events",),
      new NotificationsPage(showDrawer: widget.showDrawer, user: widget.user),
      new ProfilePage(showDrawer: widget.showDrawer, user: widget.user,)
    ];


    Widget pageView = new PageView(
      children: _views,
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
    );


//    FloatingActionButton _addButton = new FloatingActionButton(
//        child: new Icon(Icons.add),
//        onPressed: () {
//          Navigator.of(context).push(new MaterialPageRoute(
//              builder: (BuildContext build) {
//                return new AddGroupForm();
//              }
//          )).then((bool val){
//            if(val) {
//              _scaffoldKey.currentState.showSnackBar(new SnackBar(
//                  content: new Text("Upload Success")
//              )
//              );
//            }else{
//              _scaffoldKey.currentState.showSnackBar(new SnackBar(
//                  content: new Text("Upload Failed"),
//                  action: new SnackBarAction(label: "Retry", onPressed: (){})
//              )
//              );
//            }
//          });
//        }
//    );


    return new Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: botNavBar,

        body: pageView
//      floatingActionButton: _index == 0 ? _addButton : null,  // keeps the animation if we leave it high in tree


    );
  }
}

addGroup(BuildContext context) {
  Navigator.of(context).push(new MaterialPageRoute<bool>(
      builder: (BuildContext build) {
        return new AddGroupForm();
      },
      fullscreenDialog: true

  ));
}

