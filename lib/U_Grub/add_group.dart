import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_grub2/U_Grub/user.dart';
import 'login.dart';
import 'image_converter.dart';

class AddGroupForm extends StatefulWidget {
  @override
  _AddGroupFormState createState() => new _AddGroupFormState();
}

class _AddGroupFormState extends State<AddGroupForm> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();

  GroupData group = new GroupData();
  ContactInfoData groupContact = new ContactInfoData();

  bool _hasBeenEdited = false;
  bool _autoValidate = false;
  bool _imageError = false;

  Future<bool> _onWillPop() async {
    final FormState form = _formKey.currentState;
    form.save();
    if(_hasBeenEdited)

    if (checkIfEmpty())
      return true;

    return await showDialog<bool>(
        context: context,
        child: new AlertDialog(
            content: new Text("Discard new group?"),
            actions: <Widget>[
              new FlatButton(
                  child: const Text(
                    'CANCEL',),
                  onPressed: () {
                    Navigator.of(context).pop(
                        false); // Pops the confirmation dialog but not the page.
                  }
              ),
              new FlatButton(
                  child: const Text(
                    'DISCARD', style: const TextStyle(color: Colors.red),),
                  onPressed: () {
                    Navigator.of(context).pop(
                        true); // Returning true to _onWillPop will pop again.
                  }
              ),
            ]
        )
    ) ?? false;
  }

  bool checkIfEmpty() {
    if (group.name != "") return false;

    if (group.description != "") return false;

    if (imageFile != null) return false;

    _hasBeenEdited = true;
    return true;
  }

  String _validateName(String val) {
    _hasBeenEdited = true;
    if (val.isEmpty)
      return 'Name is required.';
    final RegExp nameExp = new RegExp(r'^[A-za-z ]+$');
    if (!nameExp.hasMatch(val))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String _validateDescription(String val) {
    _hasBeenEdited = true;
    if (val.isEmpty)
      return 'Description is required.';
    return null;
  }

  String _validateEmail(String val) {
//    _hasBeenEdited = true;
//    if(val == ""){
//      return null;
//    }
//    final RegExp nameExp = new RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
//    if (!nameExp.hasMatch(val))
//      return 'Please enter a valid email address.';
//    return null;
    return null;
  }
  /*
  String _validatePhoneNumber(String value) {
    _hasBeenEdited = true;

    if (value == "") {
      return null;
    }

    final RegExp phoneExp = new RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(value))
      return '(###) ###-#### - Please enter a valid US phone number.';
    return null;
  }
  */
  _submitForm() async {
    if (imageFile == null) {
      setState(() {
        _imageError = true;
      });
    }
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    //Everything is good to go on the upload so pop back
    // to the group view and add a snackbar when its done
    showDialog(
        context: context,
        barrierDismissible: false,
        child: new AlertDialog(
          content: new Container(child: new CircularProgressIndicator()),
          actions: <Widget> [
            new FlatButton(
                onPressed: _handleCancelUpload,
                child: new Text("CANCEL", style: new TextStyle(color: Colors.red)))
          ],


        ),

    );

    uploadInfo(group, groupContact, imageFile).then((bool didSubmit){
      Navigator.of(context).pop();
      if(didSubmit) {
        Navigator.of(context).pop(true);
      }
      else {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text("Upload Failed"),
            action: new SnackBarAction(label: "Retry", onPressed: (){
              _submitForm();
            })
        )
        );
      }
    });

  }
  _handleCancelUpload() {

  }


  File imageFile;

  _imageSelector() async {
    var _file = await ImagePicker.pickImage();

    setState(() {
      imageFile = _file;
    });
  }

  _previewImage() {
    Navigator.push(context, new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          Color saveColor = Theme
              .of(context)
              .brightness == Brightness.light ? Colors.white : Theme
              .of(context)
              .accentColor;
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("Group Image"),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _imageSelector();
                    },
                    child: new Text("Change",
                      style: Theme
                          .of(context)
                          .textTheme
                          .button
                          .copyWith(color: saveColor),)
                )
              ],
            ),
            body: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Image.file(imageFile, height: 256.0,),
                ]
            ),


          );
        }
    ));
  }

  @override
  Widget build(BuildContext context) {
    Color saveColor = Theme
        .of(context)
        .brightness == Brightness.light ? Colors.white : Theme
        .of(context)
        .accentColor;


    Color imageSelectorColor = _imageError ? Colors.red : Colors.black54;

    Widget _image_selector = new InkWell(
        onTap: imageFile == null ? _imageSelector : _previewImage,
        onLongPress: _imageSelector,
        child: new Container(
            width: 100.0,
            padding: const EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                imageFile == null ? new Icon(
                  Icons.group, size: 70.0, color: Colors.black54,) :
                new Image.file(imageFile, fit: BoxFit.scaleDown,),
                imageFile == null ? new FittedBox(
                  child: new Text("Add Image *", style: Theme
                      .of(context)
                      .textTheme
                      .button
                      .copyWith(color: imageSelectorColor)),
                  fit: BoxFit.scaleDown,
                  alignment: FractionalOffset.center,

                ) : new Container()
              ],
            )
        )
    );

    Widget _nameInput = new Expanded(
      child: new Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: new TextFormField(
          decoration: new InputDecoration(
              labelText: "Name *",
              hintText: "What is your groups name?"
          ),
          onSaved: (String name) {
            group.name = name;
          },
          validator: _validateName,


        ),
      ),


    );

    Widget descriptionInput = new Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: new TextFormField(
          decoration: new InputDecoration(
            labelText: "Description *",
            hintText: "Tell a little about your group.",
          ),
          maxLines: 3,
          onSaved: (String description) {
            group.description = description;
          },
          validator: _validateDescription,

        )
    );

    Widget contactInfoForm = new Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      alignment: FractionalOffset.topLeft,
      child: new Column(
        children: <Widget>[
          new Text("Contact: ", style: Theme
              .of(context)
              .textTheme
              .title
              .copyWith(color: Colors.black54),),

          new TextFormField(
            decoration: new InputDecoration(
                labelText: "Email",
                hintText: "Where can your group can be reached?",
                helperText: "In form joesmith@example.com"
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            onSaved: (String email) {
              groupContact.email = email;
            },
          ),

        ],
      ),

    );


    Widget _form = new ListView(
      children: <Widget>[
        new Row(
          children: <Widget>[
            _image_selector,
            _nameInput,
          ],
        ),
        descriptionInput,
        new Divider(height: 30.0,),
        contactInfoForm,


      ],
    );

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Create Group"),
          actions: <Widget>[
            new FlatButton(
                onPressed: _submitForm,
                child: new Text("Submit",
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2
                        .copyWith(color: saveColor))
            )
          ],
        ),
        body: new Container(
          child: new Form(
              key: _formKey,
              autovalidate: _autoValidate,
              onWillPop: _onWillPop,
              child: _form
          ),
        )
    );
  }
}

/*@required this.name,
    @required this.description,
    @required this.image,
    this.members,
    this.contactInfo,
    this.events  */


class GroupData {
  String name;
  String description;
  String image;
  ContactInfoData contactInfo;
}

class ContactInfoData {
  String email;
  String phoneNumber;
  String facebookLink;
}



Future<bool> uploadInfo(GroupData group,
    ContactInfoData groupContact, File imageFile) async {

  await login();

  String image = await _uploadImage(imageFile, 800); // width is 800
  String thumbnail = await _uploadImage(imageFile, 120);



  String name = group.name;
  String description = group.description;
  String email = groupContact.email;
  String phone = groupContact.phoneNumber;
  String facebookLink = groupContact.facebookLink;



  User currentUser = new User(
    name: googleSignIn.currentUser.displayName,
    image: googleSignIn.currentUser.photoUrl,
    Id: googleSignIn.currentUser.id,
  );


  // upload to DB
  DatabaseReference ref = FirebaseDatabase.instance.reference().child(
      "groups");


  await ref.push().set({
    'name': name,
    'description': description,
    'image': image,
    'thumbnail' : thumbnail,
    'contactInfo': {
      'email': email,
      'phone': phone,
      'facebook': facebookLink
    },
    'events': {
    },
    'members': {
      currentUser.Id: {
        'name': currentUser.name,
        'image': currentUser.image
      }
    },
    'admins': {
      currentUser.Id: {
        'name': currentUser.name,
        'image': currentUser.image
      }
    }
  });

  return true;
}

_uploadImage(File imageFile, int size) async {

  // create thumbnail version
  // extremely expensive, won't run on my phone
  File newImageFile = convertToSize(imageFile, size);



  int unique_num = new Random().nextInt(10000000);
  StorageReference ref = FirebaseStorage.instance.ref().child(
      "image_$unique_num.jpg");
  StorageUploadTask uploadTask = ref.put(newImageFile);
  Uri downloadUrl = (await uploadTask.future).downloadUrl;
  return downloadUrl.toString();
}