import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'events.dart';
import 'groups.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:u_grub2/U_Grub/add_group.dart';
import 'package:u_grub2/U_Grub/home_feed.dart';
import 'package:u_grub2/U_Grub/notifications_page.dart';
import 'profile_page.dart';


class MainFeed extends StatefulWidget {
  const MainFeed({
    Key key,
    this.currentLocation,
    this.showDrawer,
    this.user

  }) : super(key: key);

  final showDrawer;
  final GoogleSignInAccount user;
  final currentLocation;

  @override
  _MainFeedState createState() => new _MainFeedState();
}

class _MainFeedState extends State<MainFeed> with TickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();

  int _index = 0;


  @override
  void initState() {
    super.initState();
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
              icon: new Icon(Icons.event), title: _index == 1 ? new Text("Saved") : new Text("")),
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
        'events');


    List<Widget> _views = [
//        new Container(
//            child: new GroupFeed(),
//            padding: const EdgeInsets.only(top: 10.0),
//        ),

      new HomePageFeed(user: widget.user, showDrawer: widget.showDrawer, currentLocation : widget.currentLocation),
      new EventFeed(query: query, showDrawer: widget.showDrawer, hasAppBar: true,),
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

