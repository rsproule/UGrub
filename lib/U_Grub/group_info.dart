import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'groups.dart';
import 'event_info.dart';
import 'events.dart';
import 'user.dart';


class GroupInfoPage extends StatefulWidget {
  const GroupInfoPage({
    Key key,
    @required this.group
  })
      : assert(group != null),
        super(key: key);

  final GroupItem group;

  @override
  _GroupInfoPageState createState() => new _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {


  Widget _builder(BuildContext context) {

    List<Widget> _eventTiles = [];
    for (MyEvent ev in widget.group.events){
      _eventTiles.add(new GridItem(event: ev));

    }


    final Orientation orientation = MediaQuery
        .of(context)
        .orientation;

    return new CustomScrollView(
      slivers: <Widget>[
        new SliverAppBar(
          expandedHeight: 256.0,
          pinned: true,
          flexibleSpace: new FlexibleSpaceBar(
            title: new Text(widget.group.name),
            background: new Stack(
              fit: StackFit.expand,
              children: <Widget>[
                new FittedBox(
                  child: widget.group.imgFile,
                  fit: BoxFit.fill,
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
                  description: widget.group.description,
                  members: widget.group.members,
                  contactInfo: widget.group.contactInfo,
              ),
              new Container(
                padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                child: new Text("Events:", style: Theme.of(context).textTheme.title),
              ),
              new Divider(),
              _eventTiles.length == 0 ?
              new Center(heightFactor: 5.0 ,child: new Text("No Events Listed")):
              new GridView.count(
                shrinkWrap: true,
                primary: false,
                crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                padding: const EdgeInsets.all(4.0),
                childAspectRatio: (orientation == Orientation.portrait)
                    ? 1.0
                    : 1.3,
                children: _eventTiles,
              )
            ])
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Builder(builder: _builder)
    );
  }
}


class GridItem extends StatefulWidget {
  const GridItem({
    this.event
});

  final MyEvent event;


  @override
  _GridItemState createState() => new _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isFlag;

  @override
  initState(){
    super.initState();
    isFlag = widget.event.isFlagged;
  }


  void onBannerTap(){
    setState((){
      isFlag = !isFlag;
    });

    String actionName = isFlag ? " added to" : " removed from";
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(widget.event.title + actionName + " flagged events."),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.black54,
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    MyEvent event = widget.event;
    final Widget image = new GestureDetector(

        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext build){
                return new EventInfoPage(event: event);
              }
          )
          );
        },
        child: new Hero(

            key: new Key(event.hashCode.toString()),
            tag: event.title,
            child: new Image.network(event.image, fit: BoxFit.cover),

        )
    );


    final IconData icon = isFlag ? Icons.flag : Icons.outlined_flag;


    return new GridTile(

      footer: new GestureDetector(
        onTap: () { onBannerTap(); },
        child: new GridTileBar(
          backgroundColor: Colors.black45,
          title: new FittedBox(
            fit: BoxFit.scaleDown,
            alignment: FractionalOffset.centerLeft,
            child: new Text(event.title),
          ),
          subtitle: new FittedBox(
            fit: BoxFit.scaleDown,
            alignment: FractionalOffset.centerLeft,
            child: new Text(event.organization),
          ),
          trailing: new Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
      child: image,
    );
  }
}

class About extends StatelessWidget {
  final String description;
  final ContactInfo contactInfo;
  final List<User> members;

  const About({
    this.description,
    this.contactInfo,
    this.members
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

    final String numMembers = this.members.length.toString() + " Member" + (this.members.length==1 ? "": "s");


    Widget memberHeader = new Container(
      padding: const EdgeInsets.all(10.0),
      child: new Text(numMembers+ ":", style: descriptionStyle,),
    );

    List<Widget> _memberTiles = [memberHeader, new Divider()];

    for (User m in members){
      _memberTiles.add(new MemberTile(member: m,));
    }


    Widget header = new Text("About",
        style: descriptionStyle.copyWith(color: color, fontSize: 28.0));
    Widget descrip = new Text(description, style: descriptionStyle);

    Widget headerContact = new Text("Contact",
        style: descriptionStyle.copyWith(color: color, fontSize: 28.0));
    Widget phone = new Row(children: <Widget>[
      new Icon(Icons.phone, color: color),
      new Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: new Text(contactInfo.phoneNumber, style: descriptionStyle,),
      )
    ],);

    Widget email = new Row(children: <Widget>[
      new Icon(Icons.email, color: color,),
      new Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: new Text(contactInfo.email, style: descriptionStyle,),
      )

    ],);

    Widget membersButton = new MaterialButton(
        onPressed: (){
          showDialog(
              context: context,
              child: new Dialog(
                child: new ListView(
                 children: _memberTiles,
                 shrinkWrap: true,
                ),
              )
          );
        },
        child: new Text(numMembers),
        color: Theme.of(context).accentColor,
    );


    List<Widget> col = [
      header,
      new Divider(color: Colors.transparent, height: 6.0,),
      descrip,
      new Divider(color: Colors.transparent, height: 17.0,),
      headerContact,
      new Divider(color: Colors.transparent, height: 4.0,),
      phone,
      new Divider(color: Colors.transparent, height: 4.0,),
      email,
      new Divider(color: Colors.transparent, height: 16.0,),
      new Center(child: membersButton,)


    ];

    return new Container(
      child: new Column(
        children: col, crossAxisAlignment: CrossAxisAlignment.start,),
      padding: const EdgeInsets.only(
          top: 30.0, bottom: 20.0, left: 25.0, right: 25.0),
    );
  }
}

class MemberTile extends StatelessWidget {
  const MemberTile({
    this.member,
    this.onTap
  });

  final User member;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(member.name),
      leading: new CircleAvatar(
        child: new Image.network(member.image)
      ),
      onTap: this.onTap
    );
  }

}


