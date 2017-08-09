import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'event_info.dart';
import 'events.dart';
import 'group_info.dart';

class SideScrollItem extends StatefulWidget {
  const SideScrollItem({
    this.type: GridItemType.none,
    this.event,
    this.user

  });

  final GridItemType type;
  final MyEvent event;
  final GoogleSignInAccount user;

  @override
  _SideScrollItemState createState() => new _SideScrollItemState();
}

class _SideScrollItemState extends State<SideScrollItem> {

  bool isFlagged;


  bool checkIsFlagged(Map flags, GoogleSignInAccount user) {
    if(flags != null) {
      return flags.containsKey(user.id);
    }else return false;
  }




  _buildLeadingWidget(String val, IconData icon) {
    return new Row(
      children: <Widget>[
        new Expanded(child: new Container()),
        new Container(
          color: Colors.black54,
          padding: const EdgeInsets.all(4.0),
          child: new Row(
              children: <Widget>[
                new Container(padding: const EdgeInsets.only(right: 5.0),
                    child: new Icon(icon, color: Colors.white,)
                ),
                new Text(val, style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white),),

              ]),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    switch (widget.type) {
      case GridItemType.popular:
        return _buildLeadingWidget(widget.event.score.toString(), Icons.whatshot);

      case GridItemType.upcoming:
        int daysTill =widget.event.date.difference(new DateTime.now()).inDays;
        String s = daysTill == 1 ? "" : "s";
        String msg = daysTill.toString() + " day" + s + " till";
        if (daysTill == 0) {
          msg = "Today";
        }
        return _buildLeadingWidget(msg, Icons.today);

      case GridItemType.nearby:
        String msg = widget.event.distance.toString() + " miles";
        return _buildLeadingWidget(msg, Icons.location_on);

      case GridItemType.none:
        return new Container();

      default:
        return new Container();
    }
  }



  Widget _buildChild(){
    Random r = new Random();
    String uniqueId = widget.event.title + r.nextInt(10000).toString();
    final Widget image = new GestureDetector(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext build) {
                return new EventInfoPage(event: widget.event, user: widget.user,);
              }
          )
          );
        },
        child: new Hero(

          key: new Key(widget.event.hashCode.toString()),
          tag: uniqueId,
          child: new Image.network(widget.event.image, fit: BoxFit.cover),

        )
    );

    return image;
  }

  Widget _buildFooter(){
    Widget flagWidget = new IconButton(
        icon: isFlagged ? new Icon(Icons.flag) : new Icon(Icons.outlined_flag),
        onPressed: (){
          setState((){
            isFlagged = !isFlagged;
          });
        },
    );

    Widget footerBar = new GridTileBar(
          backgroundColor: Colors.black45,
          title: new FittedBox(
            fit: BoxFit.scaleDown,
            alignment: FractionalOffset.centerLeft,
            child: new Text(widget.event.title),
          ),
          subtitle: new FittedBox(
            fit: BoxFit.scaleDown,
            alignment: FractionalOffset.centerLeft,
            child: new Text(widget.event.organization),
          ),
          trailing: flagWidget

    );
    return footerBar;
  }

  @override
  Widget build(BuildContext context) {
    isFlagged = widget.event.isFlagged;

    return new Container(
      width: 200.0,
      height: 200.0,
      padding: const EdgeInsets.all(10.0),
      child: new Card(
        elevation: 5.0,
        child: new GridTile(
          header: _buildHeader(),
          child: _buildChild(),
          footer: _buildFooter(),
        ),
      ),
    );
  }
}

