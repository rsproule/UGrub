import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'events.dart';

class EventInfoPage extends StatefulWidget {
  const EventInfoPage({
    Key key,
    this.event
  }) : super(key: key);

  final MyEvent event;

  @override
  _EventInfoPageState createState() => new _EventInfoPageState();
}

class _EventInfoPageState extends State<EventInfoPage> {

  Widget _bodyBuilder(BuildContext context) {
    MyEvent event = widget.event;
    return new CustomScrollView(
      slivers: <Widget>[
        new SliverAppBar(

          actions: <Widget>[
            new PopupMenuButton(
                onSelected: (String selected) {
                  _showScaffold(
                      context, 'You pressed snackbar $selected\'s action.');
                },
                itemBuilder: (BuildContext context) =>
                <PopupMenuItem<String>>[
                  _buildMenuItem(Icons.map, "View in Map"),
                  _buildMenuItem(Icons.calendar_today, "Open in calendar"),
                  _buildMenuItem(Icons.share, "Share"),
                  _buildMenuItem(Icons.flag, "Flag this Event")
                ]
            )
          ],
          expandedHeight: 256.0,
          pinned: true,
          flexibleSpace: new FlexibleSpaceBar(
            title: new Text(event.title),
            background: new Stack(
              fit: StackFit.expand,
              children: <Widget>[
                new Image.network(
                  event.image,
                  fit: BoxFit.cover,
                  height: 256.0,
                ),

                // This gradient ensures that the toolbar icons are distinct
                // against the background image.
                const DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: const LinearGradient(
                      begin: const FractionalOffset(0.5, 0.0),
                      end: const FractionalOffset(0.5, 0.30),
                      colors: const <Color>[
                        const Color(0x60000000), const Color(0x00000000)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        new SliverList(
            delegate: new SliverChildListDelegate(<Widget>[

              new About(
                description: event.description,
                foodType: event.foodType,
                organization: event.organization,
              ),
              new Divider(),

              new DateTimeInfo(
                date: event.getDateString(),
                startsOn: event.startTime,
                endsOn: event.endTime,
              ),
              new Divider(),
              new Location(location: event.location)


            ])
        )

      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Builder(
            builder: _bodyBuilder
        )
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String label) {
    Color color = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.black : Theme
        .of(context)
        .accentColor;
    return new PopupMenuItem<String>(
      value: label,
      child: new Row(
        children: <Widget>[
          new Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: new Icon(icon, color: color)
          ),
          new Text(label),
        ],
      ),
    );
  }

  void _showScaffold(BuildContext context, String s) {
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(s)
    ));
  }
}

class About extends StatelessWidget {
  final String description;
  final String organization;
  final foodType;

  const About({
    this.description,
    this.organization,
    this.foodType
  });


  @override
  Widget build(BuildContext context) {
    TextStyle descriptionStyle = Theme
        .of(context)
        .brightness == Brightness.light ? Theme
        .of(context)
        .textTheme
        .subhead
        .copyWith(
        fontFamily: "Raleway",
        textBaseline: TextBaseline.alphabetic,
        color: Colors.black54
    ) : Theme
        .of(context)
        .textTheme
        .subhead;

    Color color = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.black : Theme
        .of(context)
        .accentColor;


    Widget header = new Text("About",
        style: descriptionStyle.copyWith(color: color, fontSize: 28.0));
    Widget descrip = new Text("     " + description, style: descriptionStyle);

    Widget food = new Text(
      foodType.toString().replaceAll('[', "").replaceAll("]", ""),
      style: descriptionStyle,);
    if (foodType is String) {
      food = new CategoryTag(category: foodType.toString().replaceAll('[', ""),
        style: descriptionStyle, color: color);
    }
    else if (foodType is List) {
      List<Widget> _categories = [];
      for (String f in foodType) {
        Widget cat = new CategoryTag(
            category: f.replaceAll("[", "").replaceAll(",", "").replaceAll(
                "]", ""), style: descriptionStyle, color : color);
        _categories.add(cat);
      }
      List<Widget> formatted = [];
      int i = 0;
      while(i < _categories.length){
        Widget tempRow =  new Row(
          children: _categories.sublist(i, i+2),
        );

        formatted.add(tempRow);
        i+=2;

      }

      food = new Column(
        children: formatted
      );
    }


    Widget org = new Row(children: <Widget>[
      new Icon(Icons.group, color: color,),
      new Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: new Text(organization, style: descriptionStyle),
      )

    ],);


    List<Widget> col = [
      header,
      new Divider(color: Colors.transparent, height: 6.0,),
      descrip,
      new Divider(color: Colors.transparent, height: 10.0,),
      org,
      new Divider(color: Colors.transparent, height: 4.0,),
      food
    ];

    return new Container(
      child: new Column(
        children: col, crossAxisAlignment: CrossAxisAlignment.start,),
      padding: const EdgeInsets.only(
          top: 30.0, bottom: 20.0, left: 25.0, right: 25.0),
    );
  }
}


class CategoryTag extends StatelessWidget {
  const CategoryTag({
    this.category,
    this.style,
    this.color
  });

  final Color color;
  final TextStyle style;
  final String category;

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(4.0),
        decoration: new BoxDecoration(
            borderRadius: const BorderRadius.all(
                const Radius.elliptical(30.0, 30.0)),
            color: color
        ),
        child: new InkWell(
              splashColor: Colors.black45,
              highlightColor: Colors.black12,
              onTap: () {
                DatabaseReference query = FirebaseDatabase.instance.reference()
                    .child("categories")
                    .child(category);
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext build) {
                      return new EventFeed(
                        query: query, hasAppBar: true, title: category,);
                    }
                )
                );
              },
              child: new Text(category, style: style,)
        ),

    );
  }
}

class DateTimeInfo extends StatelessWidget {
  const DateTimeInfo({
    Key key,
    this.date,
    this.startsOn,
    this.endsOn
  }) : super(key: key);

  final String date;
  final String startsOn;
  final String endsOn;


  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme
        .of(context)
        .brightness == Brightness.light ? Theme
        .of(context)
        .textTheme
        .subhead
        .copyWith(
        fontFamily: "Raleway",
        textBaseline: TextBaseline.alphabetic,
        color: Colors.black54
    ) : Theme
        .of(context)
        .textTheme
        .subhead;

    Color color = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.black : Theme
        .of(context)
        .accentColor;

    Widget header = new Text(
      "When", style: style.copyWith(color: color, fontSize: 28.0),);
    Widget dateWidget = new Text(date, style: style,);
    Widget timeWidget = new Text(startsOn + " - " + endsOn, style: style,);

    List<Widget> col = [
      header,
      new Divider(color: Colors.transparent, height: 6.0,),
      dateWidget,
      new Divider(color: Colors.transparent, height: 4.0,),
      timeWidget
    ];


    return new Container(
      child: new Column(
        children: col, crossAxisAlignment: CrossAxisAlignment.start,),
      padding: const EdgeInsets.only(
          top: 12.0, bottom: 20.0, left: 25.0, right: 25.0),
    );
  }
}

class Location extends StatelessWidget {
  const Location({
    Key key,
    @required this.location,
    this.geolocation
  })
      : assert(location != null),
        super(key: key);

  final String location;
  final geolocation;

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme
        .of(context)
        .brightness == Brightness.light ? Theme
        .of(context)
        .textTheme
        .subhead
        .copyWith(
        fontFamily: "Raleway",
        textBaseline: TextBaseline.alphabetic,
        color: Colors.black54
    ) : Theme
        .of(context)
        .textTheme
        .subhead;

    Color color = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.black : Theme
        .of(context)
        .accentColor;

    Widget header = new Text(
      "Where", style: style.copyWith(color: color, fontSize: 28.0),);

    Widget loc = new Row(children: <Widget>[
      new Icon(Icons.location_on, color: color,),
      new Text("  " + location, style: style)
    ],);

    List<Widget> col = [
      header,
      new Divider(color: Colors.transparent, height: 6.0,),
      loc,
      new Divider(color: Colors.transparent, height: 16.0,),
      new Image.network("http://52.14.73.202/~rsproule/misc/mapimg.png")

    ];

    return new Container(
      child: new Column(
        children: col, crossAxisAlignment: CrossAxisAlignment.start,),
      padding: const EdgeInsets.only(
          top: 12.0, bottom: 20.0, left: 25.0, right: 25.0),
    );
  }
}



