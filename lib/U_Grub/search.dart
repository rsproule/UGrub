import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
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
        new SliverList(
        delegate: new SliverChildListDelegate(<Widget>[
          isSearching ?
            new ListView(
              shrinkWrap: true,
              children: <Widget>[
                new ListTile(
                  title: new Text("Search Result 1"),
                ),new ListTile(
                  title: new Text("Search Result 2"),
                ),new ListTile(
                  title: new Text("Search Result 3"),
                ),new ListTile(
                  title: new Text("Search Result 4"),
                ),new ListTile(
                  title: new Text("Search Result 5"),
                ),
              ],
            ) :
              new Center(heightFactor: 20.0 ,child: new Text("Type to Search"),)
        ]))

      ]),

    );
  }
}
