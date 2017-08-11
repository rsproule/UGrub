import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:u_grub2/U_Grub/event_info.dart';
import 'package:u_grub2/U_Grub/events.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    @required this.user
  });

  final GoogleSignInAccount user;
  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController _searchQuery = new TextEditingController();

  bool isSearching = false;



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
            onChanged: (String search){
              if(search != ""){
                setState((){
                  isSearching = true;
                });
              }else{
                setState((){
                  isSearching = false;
                });
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

  @override
  Widget build(BuildContext context) {
    final double systemTopPadding = MediaQuery.of(context).padding.top;

    Widget dynamicAppBar = new SliverAppBar(
      iconTheme: IconTheme.of(context),

      elevation: 0.0,
      flexibleSpace: new Container(
          padding:
          new EdgeInsets.only(top: systemTopPadding, left: 5.0, right: 5.0),
          child: buildSearchBar()),
      backgroundColor: Colors.transparent,
      pinned: true,
    );

    return new Scaffold(
      body: new CustomScrollView(slivers: <Widget>[
        dynamicAppBar,

        new SliverFillRemaining(
          child: isSearching ?
          buildSearchResults(_searchQuery.text):
          new Center(heightFactor: 20.0 ,child: new Text("Type to Search"),)
          ,
        ),


      ]),

    );
  }

  buildSearchResults(String search) {
    DatabaseReference query = FirebaseDatabase.instance.reference().child("events");
    Comparator time = (a, b) {

      DateTime aDate = DateTime.parse(a.value['date']);
      DateTime bDate = DateTime.parse(b.value['date']);
      return aDate.compareTo(bDate);
    };

    return(
      new FirebaseAnimatedList(
        query: query,
        primary: true,
        sort: time,
        defaultChild: new Center(heightFactor: 20.0 ,child: new CircularProgressIndicator(),),

        shrinkWrap: true,
        itemBuilder: (_, DataSnapshot snap, Animation<double> anim) {
          if (search != null) {
            RegExp sReg = new RegExp(r"(" + search + ")", caseSensitive: false);

            if (sReg.hasMatch(snap.value['title']) ||
                sReg.hasMatch(snap.value['organization'])) {
              String latitude = null;
              String longitude = null;
              if (snap.value['geolocation'] != null) {
                latitude = snap.value['geolocation']['latitude'];
                longitude = snap.value['geolocation']['longitude'];
              }

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
                  isFlagged: isFlagged(snap.value['flags'], widget.user)
              );

              String description = snap.value['description'];
              if (description.length > 100) {
                description = description.substring(0, 100) + "...";
              }
              return new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(snap.value['title']),
                    onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext build) {
                            return new EventInfoPage(
                                event: event, user: widget.user);
                          }
                      )
                      );
                    },
                    subtitle: new Text(description),
                  ),
                  new Divider(height: 0.0,)
                ],
              );
            }


            else {
              return new Container();
            }
          }
          }
          ,

      )
    );

  }

  isFlagged(Map flags, GoogleSignInAccount user) {
    if(flags != null) {
      return flags.containsKey(user.id);
    }else return false;
  }
}
