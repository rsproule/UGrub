import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomePageFeed extends StatefulWidget {
  const HomePageFeed({
    Key key,
    this.showDrawer,
    this.user
  }) : super(key: key);

  final showDrawer;
  final GoogleSignInAccount user;

  @override
  _HomePageFeedState createState() => new _HomePageFeedState();
}

class _HomePageFeedState extends State<HomePageFeed> {


  @override
  Widget build(BuildContext context) {
    return new CustomScrollView(
        slivers: <Widget>[

          new SliverAppBar(
            elevation: 0.0,
            flexibleSpace: new Card(
              elevation: 5.0,
              child: new ListTile(

                title: new TextFormField(
                  decoration: new InputDecoration(
                      hintText: "Search",
                      hideDivider: true
                  ),
                  style: Theme
                      .of(context)
                      .textTheme
                      .title,
                ),
                leading: new Icon(Icons.search),

              ),
            ),
            backgroundColor: Colors.transparent,
            pinned: true,

          ),
          new SliverList(
              delegate: new SliverChildListDelegate(<Widget>[
                new Container(
                  height: 900.0,
                  color: Colors.blue,
                )
              ])
          )

        ]
    );
  }
}
