import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'events.dart';

class FoodTile extends StatelessWidget {
  const FoodTile({this.image, this.name, this.events, this.query, this.count});

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
            child: new Row(children: <Widget>[
              new Container(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: new Icon(
                    icon,
                    color: Colors.white,
                  )),
              new Text(
                val,
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
            ]),
          ),
        ],
      );
    }

    return new Container(
      child: new GestureDetector(
        onTap: () {
          Navigator
              .of(context)
              .push(new MaterialPageRoute(builder: (BuildContext build) {
            return new EventFeed(
              query: query,
              hasAppBar: true,
              title: name,
            );
          }));
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
          header: _buildLeadingWidget(count.toString(), Icons.event_available),
        ),
      ),
    );
  }
}
