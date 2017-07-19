import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'events.dart';
import 'groups.dart';
import 'package:u_grub2/U_Grub/add_group.dart';


class MainFeed extends StatefulWidget {
  const MainFeed({
      Key key,

  }) : super(key: key);



  @override
  _MainFeedState createState() => new _MainFeedState();
}

class _MainFeedState extends State<MainFeed> with TickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();

  int _index = 1;


  @override
  void initState(){
    super.initState();

  }

  @override
  void dispose(){
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    Widget botNavBar = new BottomNavigationBar(
      onTap: (int index){
        setState((){
          _index = index;
        });
      },
      items: <BottomNavigationBarItem>[
        new BottomNavigationBarItem(icon: new Icon(Icons.group), title: new Text("Groups")),
        new BottomNavigationBarItem(icon: new Icon(Icons.event), title: new Text("Upcoming Events")),
        new BottomNavigationBarItem(icon: new Icon(Icons.search), title: new Text("Explore")),
      ],
      currentIndex: _index,

    );

    //all events query
    DatabaseReference query = FirebaseDatabase.instance.reference().child('events');

    List<Widget> _views = [
        new Container(
            child: new GroupFeed(),
            padding: const EdgeInsets.only(top: 10.0),
        ),
        new EventFeed(query: query,),
        new Center(child: new Text("Explore")),
    ];



    FloatingActionButton _addButton = new FloatingActionButton(
        child: new Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext build) {
                return new AddGroupForm();
              }
          )).then((bool val){
            if(val) {
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                  content: new Text("Upload Success")
              )
              );
            }else{
              _scaffoldKey.currentState.showSnackBar(new SnackBar(
                  content: new Text("Upload Failed"),
                  action: new SnackBarAction(label: "Retry", onPressed: (){})
              )
              );
            }
          });
        }
    );


    return new Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: botNavBar,
      body: _views[_index],
      floatingActionButton: _index == 0 ? _addButton : null,  // keeps the animation if we leave it high in tree


    );

  }
}

 addGroup(BuildContext context){
    Navigator.of(context).push(new MaterialPageRoute<bool>(
        builder: (BuildContext build) {
          return new AddGroupForm();
        },
      fullscreenDialog: true

    ));

}

