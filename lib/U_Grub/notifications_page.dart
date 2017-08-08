import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    Key key,
    this.user,
    this.showDrawer
  }) : super(key: key);

  final GoogleSignInAccount user;
  final showDrawer;

  @override
  _NotificationsPageState createState() => new _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {

    DatabaseReference query = FirebaseDatabase.instance.reference().child(
        'users').child(widget.user.id).child('notifications');

    Widget _notificationsList = new FirebaseAnimatedList(
      query: query,
      sort: (a, b) {
        return b.key.compareTo(a.key);
      },
      itemBuilder: (_, DataSnapshot snap, Animation<double> anim) {
          MyNotification noti = new MyNotification(
            from: snap.value['from'],
            title: snap.value['title'],
            isOpened: snap.value['isOpened'],
            message: snap.value['message'],
            id: snap.key,

          );

          return new Column(
            children: <Widget>[
              new NotificationTile(
                notification: noti,
                user: widget.user,
              ),
              new Divider()
            ],
          );
      },
    );


    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: widget.showDrawer
        ),
        title: new Text("Notifications"),

      ),
      body: _notificationsList
    );
  }
}

class NotificationTile extends StatefulWidget {
  const NotificationTile({
    this.notification,
    this.user
  });

  final MyNotification notification;
  final GoogleSignInAccount user;
  @override
  _NotificationTileState createState() => new _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(widget.notification.title),
      subtitle: new Text(widget.notification.message),
      leading: !widget.notification.isOpened ?
      new Icon(Icons.notifications, color: Colors.red,) :
      new Icon(Icons.notifications_none),
      onTap: (){
        DatabaseReference ref = FirebaseDatabase.instance.reference().child('users').child(widget.user.id).child(
            "notifications").child(widget.notification.id).child('isOpened');

        ref.set(true);

        // TODO open the event info page that this noti is referring to



      },
    );
  }
}


class MyNotification {
  const MyNotification({
    this.id,
    this.message,
    this.title,
    this.from,
    this.isOpened
  });

  final String id;
  final String message;
  final String title;
  final String from;
  final bool isOpened;
}
